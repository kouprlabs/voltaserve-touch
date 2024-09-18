import SwiftUI
import VoltaserveCore

struct WorkspaceSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var onCompletion: (() -> Void)?

    init(_ onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    var body: some View {
        if let current = workspaceStore.current {
            Form {
                Section(header: VOSectionHeader("Storage")) {
                    VStack(alignment: .leading) {
                        if let storageUsage = workspaceStore.storageUsage {
                            Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                            ProgressView(value: Double(storageUsage.percentage) / 100.0)
                        } else {
                            Text("Calculating…")
                            ProgressView()
                        }
                    }
                    NavigationLink(destination: WorkspaceEditStorageCapacity()) {
                        HStack {
                            Text("Capacity")
                            Spacer()
                            Text("\(current.storageCapacity.prettyBytes())")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(isDeleting)
                }
                Section(header: VOSectionHeader("Basics")) {
                    NavigationLink(destination: WorkspaceEditName()) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(current.name)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(isDeleting)
                }
                Section(header: VOSectionHeader("Advanced")) {
                    Button(role: .destructive) {
                        showDelete = true
                    } label: {
                        HStack {
                            Text("Delete Workspace")
                            if isDeleting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            .alert("Delete Workspace", isPresented: $showDelete) {
                Button("Delete Permanently", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this workspace?")
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                if tokenStore.token != nil {
                    onAppearOnChange()
                }
            }
            .onChange(of: tokenStore.token) { _, newToken in
                if newToken != nil {
                    onAppearOnChange()
                }
            }
        } else {
            ProgressView()
        }
    }

    private func onAppearOnChange() {
        guard let current = workspaceStore.current else { return }
        fetchStorageUsage(current.id)
    }

    private func fetchStorageUsage(_ id: String) {
        var usage: VOStorage.Usage?
        VOErrorResponse.withErrorHandling {
            usage = try await workspaceStore.fetchStorageUsage(id)
        } success: {
            workspaceStore.storageUsage = usage
        } failure: { message in
            errorTitle = "Error: Fetching Storage Usage"
            errorMessage = message
            showError = true
        }
    }

    private func performDelete() {
        guard let current = workspaceStore.current else { return }

        isDeleting = true

        VOErrorResponse.withErrorHandling {
            try await workspaceStore.delete(current.id)
        } success: {
            presentationMode.wrappedValue.dismiss()
            onCompletion?()
        } failure: { message in
            errorTitle = "Error: Deleting Workspace"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }
}
