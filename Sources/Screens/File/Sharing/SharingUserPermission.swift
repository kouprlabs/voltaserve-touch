import SwiftUI
import VoltaserveCore

struct SharingUserPermission: View {
    @EnvironmentObject private var sharingStore: SharingStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var user: VOUser.Entity?
    @State private var permission: VOPermission.Value?
    @State private var showRevoke = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isGranting = false
    @State private var isRevoking = false
    private let files: [VOFile.Entity]
    private let predefinedUser: VOUser.Entity?
    private let defaultPermission: VOPermission.Value?
    private let enableCancel: Bool
    private let enableRevoke: Bool

    init(
        files: [VOFile.Entity],
        predefinedUser: VOUser.Entity? = nil,
        defaultPermission: VOPermission.Value? = nil,
        enableCancel: Bool = false,
        enableRevoke: Bool = false
    ) {
        self.files = files
        self.predefinedUser = predefinedUser
        self.defaultPermission = defaultPermission
        self.enableCancel = enableCancel
        self.enableRevoke = enableRevoke
    }

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    if let workspace = workspaceStore.current {
                        UserSelector(organizationID: workspace.organization.id) { user in
                            self.user = user
                        }
                    }
                } label: {
                    HStack {
                        Text("User")
                        if let user {
                            Spacer()
                            Text(user.fullName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(predefinedUser != nil || isGranting || isRevoking)
                Picker("Permission", selection: $permission) {
                    Text("Viewer").tag(VOPermission.Value.viewer)
                    Text("Editor").tag(VOPermission.Value.editor)
                    Text("Owner").tag(VOPermission.Value.owner)
                }
                .disabled(isGranting || isRevoking)
            }
            if enableRevoke, files.count == 1 {
                Section {
                    Button(role: .destructive) {
                        showRevoke = true
                    } label: {
                        HStack {
                            Text("Revoke Permission")
                            if isRevoking {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRevoking)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("User Permission")
        .toolbar {
            if enableCancel {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isGranting {
                    ProgressView()
                } else {
                    Button("Apply") {
                        performGrant()
                    }
                    .disabled(!isValid() || isRevoking)
                }
            }
        }
        .onAppear {
            if let predefinedUser {
                user = predefinedUser
            }
            if let defaultPermission {
                permission = defaultPermission
            }
        }
        .confirmationDialog("Revoke Permission", isPresented: $showRevoke, titleVisibility: .visible) {
            Button("Revoke", role: .destructive) {
                performRevoke()
            }
        } message: {
            Text("Are you sure you want to revoke this permission?")
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
    }

    private func performGrant() {
        guard let user, let permission else { return }
        isGranting = true
        withErrorHandling {
            for file in files {
                try await sharingStore.grantUserPermission(id: file.id, userID: user.id, permission: permission)
            }
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Granting User Permission"
            errorMessage = message
            showError = true
        } anyways: {
            isGranting = false
        }
    }

    private func performRevoke() {
        guard let user, files.count == 1, let file = files.first else { return }
        isRevoking = true
        withErrorHandling {
            try await sharingStore.revokeUserPermission(id: file.id, userID: user.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Revoking User Permission"
            errorMessage = message
            showError = true
        } anyways: {
            isRevoking = false
        }
    }

    private func isValid() -> Bool {
        user != nil && permission != nil
    }
}
