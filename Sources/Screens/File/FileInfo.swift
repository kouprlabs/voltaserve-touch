import SwiftUI
import VoltaserveCore

struct FileInfo: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: VOSectionHeader("Properties")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(file.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.secondary)
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
                            ColorBadge(fileExtension, color: .gray300, style: .fill)
                        }
                    }
                    HStack {
                        Text("Permission")
                        Spacer()
                        PermissionBadge(file.permission)
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
                            Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
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
        .voErrorAlert(
            isPresented: $showError,
            title: fileStore.errorTitle,
            message: fileStore.errorMessage
        )
        .onAppear {
            fileStore.current = file
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
        .sync($fileStore.showError, with: $showError)
    }

    private var fileType: String {
        switch file.type {
        case .file: "File"
        case .folder: "Folder"
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        fileStore.fetchStorageUsage()
        if file.type == .folder {
            fileStore.fetchItemCount()
        }
    }

    private func startTimers() {
        fileStore.startTimer()
    }

    private func stopTimers() {
        fileStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }
}
