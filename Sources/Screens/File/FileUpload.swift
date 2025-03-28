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

public struct FileUpload: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = true
    @State private var errorIsPresented = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let urls: [URL]
    private let file: VOFile.Entity?
    private let workspace: VOWorkspace.Entity

    public init(_ urls: [URL], file: VOFile.Entity? = nil, workspace: VOWorkspace.Entity, fileStore: FileStore) {
        self.urls = urls
        self.file = file
        self.workspace = workspace
        self.fileStore = fileStore
    }

    public var body: some View {
        VStack {
            if isProcessing, !errorIsPresented {
                VOSheetProgressView()
                if urls.count > 1 {
                    Text("Uploading (\(urls.count)) items.")
                } else {
                    Text("Uploading item.")
                }
            } else if errorIsPresented, errorSeverity == .full {
                VOErrorIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    dismiss()
                } label: {
                    VOButtonLabel("Done")
                }
                .voSecondaryButton()
                .padding(.horizontal)
            } else if errorIsPresented, errorSeverity == .partial {
                VOWarningIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    dismiss()
                } label: {
                    VOButtonLabel("Done")
                }
                .voSecondaryButton()
                .padding(.horizontal)
            }
        }
        .onAppear {
            performUpload()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performUpload() {
        Task {
            var failedCount = 0
            for url in urls {
                do {
                    if !url.startAccessingSecurityScopedResource() {
                        throw FileAccessError.permissionError
                    }
                    if let file {
                        _ = try await fileStore.upload(url, id: file.id)
                    } else {
                        _ = try await fileStore.upload(url, workspaceID: workspace.id)
                    }
                    if fileStore.isLastPage() {
                        fileStore.fetchNextPage()
                    }
                    url.stopAccessingSecurityScopedResource()
                } catch {
                    failedCount += 1
                }
            }
            if failedCount == 0 {
                errorIsPresented = false
                dismiss()
            } else {
                if failedCount > 1 {
                    errorMessage = "Failed to upload (\(failedCount)) items."
                } else {
                    errorMessage = "Failed to upload item."
                }
                if failedCount == urls.count {
                    errorSeverity = .full
                } else if failedCount < urls.count {
                    errorSeverity = .partial
                }
                errorIsPresented = true
            }
            isProcessing = false
        }
    }

    private enum ErrorSeverity {
        case full
        case partial
        case unknown
    }

    private enum FileAccessError: Error {
        case permissionError
    }
}
