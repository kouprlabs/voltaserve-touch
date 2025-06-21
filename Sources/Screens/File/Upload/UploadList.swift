// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI
import VoltaserveCore

public struct UploadList: View {
    @ObservedObject private var fileStore: FileStore
    @StateObject private var uploadStore = UploadStore()
    @Environment(\.dismiss) private var dismiss
    private let urls: [URL]
    private let file: VOFile.Entity?
    private let workspace: VOWorkspace.Entity
    @State private var isDone = false
    @State private var isCancelRequested = false

    public init(_ urls: [URL], file: VOFile.Entity? = nil, workspace: VOWorkspace.Entity, fileStore: FileStore) {
        self.urls = urls
        self.file = file
        self.workspace = workspace
        self.fileStore = fileStore
    }

    public var body: some View {
        NavigationStack {
            VStack {
                List(uploadStore.entities, id: \.displayID) { entity in
                    UploadRow(entity)
                        .tag(entity.id)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Uploads")
            .toolbar {
                if isDone {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                } else if isCancelRequested {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel", role: .destructive) {
                            isCancelRequested = true
                        }
                    }
                }
            }
        }
        .onAppear {
            uploadStore.clear()
            for url in urls {
                uploadStore.append([UploadStore.Entity(url, message: "Waiting.")])
            }
            performUpload()
        }
        .onDisappear {
            isCancelRequested = true
        }
        .interactiveDismissDisabled(!isDone)
    }

    private func performUpload() {
        Task {
            for url in urls {
                do {
                    if isCancelRequested {
                        DispatchQueue.main.async {
                            uploadStore.patch(url, status: .cancelled, message: "Cancelled.")
                        }
                        continue
                    }
                    if !url.startAccessingSecurityScopedResource() {
                        throw FileAccessError.permissionError
                    }
                    if let file {
                        if let data = try? Data(contentsOf: url) {
                            do {
                                try await fileStore.patch(
                                    file.id,
                                    options: .init(
                                        name: url.lastPathComponent,
                                        data: data
                                    )
                                ) { progress in
                                    DispatchQueue.main.async {
                                        uploadStore.patch(url, status: .running, progress: progress)
                                    }
                                }
                                DispatchQueue.main.async {
                                    uploadStore.patch(url, status: .success, message: "Done.")
                                    if fileStore.isLastPage() {
                                        fileStore.fetchNextPage()
                                    }
                                }
                            } catch let error as VOErrorResponse {
                                DispatchQueue.main.async {
                                    uploadStore.patch(url, status: .error, message: error.userMessage)
                                }
                            }
                        }
                    } else {
                        if let current = fileStore.current, let data = try? Data(contentsOf: url) {
                            do {
                                try await fileStore.create(
                                    .init(
                                        workspaceID: workspace.id,
                                        parentID: current.id,
                                        name: url.lastPathComponent,
                                        data: data
                                    )
                                ) { progress in
                                    DispatchQueue.main.async {
                                        uploadStore.patch(url, status: .running, progress: progress, message: "")
                                    }
                                }
                                DispatchQueue.main.async {
                                    uploadStore.patch(url, status: .success, message: "Done.")
                                    if fileStore.isLastPage() {
                                        fileStore.fetchNextPage()
                                    }
                                }
                            } catch let error as VOErrorResponse {
                                DispatchQueue.main.async {
                                    uploadStore.patch(url, status: .error, message: error.userMessage)
                                }
                            }
                        }
                    }
                } catch let error as FileAccessError {
                    DispatchQueue.main.async {
                        uploadStore.patch(url, status: .error, message: error.localizedDescription)
                    }
                }
                url.stopAccessingSecurityScopedResource()
            }
            isDone = true
        }
    }

    private enum FileAccessError: LocalizedError {
        case permissionError

        var errorDescription: String? {
            switch self {
            case .permissionError:
                return NSLocalizedString(
                    "You don’t have permission to access this file.",
                    comment: "File operation failed – lacking permissions"
                )
            }
        }
    }
}
