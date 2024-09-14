import SwiftUI
import VoltaserveCore

struct WorkspaceSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var shouldDismiss: (() -> Void)?

    init(_ shouldDismiss: (() -> Void)? = nil) {
        self.shouldDismiss = shouldDismiss
    }

    var body: some View {
        if let current = workspaceStore.current {
            Form {
                Section(header: VOSectionHeader("Storage Capacity")) {
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
                    isDeleting = true
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                        Task { @MainActor in
                            presentationMode.wrappedValue.dismiss()
                            shouldDismiss?()
                        }
                    }
                }
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
                if authStore.token != nil {
                    onAppearOnChange()
                }
            }
            .onChange(of: authStore.token) { _, newToken in
                if newToken != nil {
                    onAppearOnChange()
                }
            }
        } else {
            ProgressView()
        }
    }

    func onAppearOnChange() {
        guard let current = workspaceStore.current else { return }
        fetchStorageUsage(current.id)
    }

    private func fetchStorageUsage(_ id: String) {
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
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }
}
