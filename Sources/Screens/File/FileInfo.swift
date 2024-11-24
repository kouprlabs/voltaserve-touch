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

struct FileInfo: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @Environment(\.dismiss) private var dismiss
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    Form {
                        Section(header: VOSectionHeader("Properties")) {
                            NavigationLink {
                                Form {
                                    Text(file.name)
                                }
                                .navigationTitle(file.name)
                            } label: {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    Text(file.name)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            HStack {
                                Text("Type")
                                Spacer()
                                Text(fileType)
                                    .foregroundStyle(.secondary)
                            }
                            if let fileExtension = file.snapshot?.original.fileExtension {
                                HStack {
                                    Text("Extension")
                                    Spacer()
                                    VOColorBadge(fileExtension, color: .gray300, style: .fill)
                                }
                            }
                            HStack {
                                Text("Permission")
                                Spacer()
                                VOPermissionBadge(file.permission)
                            }
                        }
                        if let image = file.snapshot?.original.image {
                            Section(header: VOSectionHeader("Image")) {
                                HStack {
                                    Text("Dimensions")
                                    Spacer()
                                    Text("\(image.width)x\(image.height)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        if let document = file.snapshot?.original.document {
                            Section(header: VOSectionHeader("Document")) {
                                if let pages = document.pages {
                                    HStack {
                                        Text("Pages")
                                        Spacer()
                                        Text("\(pages.count)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        if file.type == .folder {
                            HStack {
                                Text("Item Count")
                                Spacer()
                                if let itemCount = fileStore.itemCount {
                                    Text("\(itemCount)")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Calculating…")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: VOSectionHeader("Storage")) {
                            VStack(alignment: .leading) {
                                if let storageUsage = fileStore.storageUsage {
                                    // swiftlint:disable:next line_length
                                    Text(
                                        "\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used"
                                    )
                                    ProgressView(value: Double(storageUsage.percentage) / 100.0)
                                } else {
                                    Text("Calculating…")
                                    ProgressView()
                                }
                            }
                        }
                        Section(header: VOSectionHeader("Time")) {
                            if let createTime = file.createTime.date?.pretty {
                                HStack {
                                    Text("Create time")
                                    Spacer()
                                    Text(createTime)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if let updateTime = file.updateTime?.date?.pretty {
                                HStack {
                                    Text("Update time")
                                    Spacer()
                                    Text(updateTime)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Info")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            fileStore.file = file
            if let token = tokenStore.token {
                assignTokenToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            fileStore.clear()
            stopTimers()
        }
    }

    private var fileType: String {
        switch file.type {
        case .file: "File"
        case .folder: "Folder"
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        fileStore.storageUsageIsLoading || fileStore.itemCountIsLoading
    }

    var error: String? {
        fileStore.storageUsageError ?? fileStore.itemCountError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        fileStore.fetchStorageUsage()
        if file.type == .folder {
            fileStore.fetchItemCount()
        }
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        fileStore.startTimer()
    }

    func stopTimers() {
        fileStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }
}
