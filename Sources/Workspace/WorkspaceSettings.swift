import SwiftUI
import Voltaserve

struct WorkspaceSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            if let workspace = workspaceStore.current {
                VStack {
                    VOAvatar(name: workspace.name, size: 100)
                    Form {
                        Section(header: Text("Storage")) {
                            VStack(alignment: .leading) {
                                if let storageUsage = workspaceStore.storageUsage {
                                    // swiftlint:disable:next line_length
                                    Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                                    ProgressView(value: Double(storageUsage.percentage) / 100.0)
                                } else {
                                    Text("Calculating…")
                                    ProgressView()
                                }
                            }
                            NavigationLink(destination: Text("Change Storage Capacity")) {
                                HStack {
                                    Text("Capacity")
                                    Spacer()
                                    Text("\(workspace.storageCapacity.prettyBytes())")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: Text("Basics")) {
                            NavigationLink(destination: Text("Change Name")) {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    Text(workspace.name)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: Text("Advanced")) {
                            Button("Delete Workspace", role: .destructive) {
                                showDelete = true
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Settings")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .alert("Delete Workspace", isPresented: $showDelete) {
                    Button("Delete Permanently", role: .destructive) {}
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you would like to delete this workspace?")
                }
                .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                    Button(VOTextConstants.errorAlertButtonLabel) {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
                .onAppear {
                    if let token = authStore.token {
                        assignTokenToStores(token)
                        fetchStorageUsage(workspace.id)
                    }
                }
                .onChange(of: authStore.token) { _, newToken in
                    if let newToken {
                        assignTokenToStores(newToken)
                        fetchStorageUsage(workspace.id)
                    }
                }
            } else {
                ProgressView()
            }
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        workspaceStore.token = token
    }

    func fetchStorageUsage(_ id: String) {
        Task {
            do {
                let usage = try await workspaceStore.fetchStorageUsage(id)
                Task { @MainActor in
                    workspaceStore.storageUsage = usage
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.userMessage
                }
            } catch {
                Task { @MainActor in
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    WorkspaceSettings()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(WorkspaceStore(
            current: VOWorkspace.Entity.devInstance
        ))
}
