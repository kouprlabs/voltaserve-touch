import SwiftUI
import VoltaserveCore

struct SharingUserPermission: View {
    @EnvironmentObject private var sharingStore: SharingStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var user: VOUser.Entity?
    @State private var permission: VOPermission.Value?
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isProcessing = false
    private let files: [VOFile.Entity]
    private let fixedUser: VOUser.Entity?
    private let defaultPermission: VOPermission.Value?

    init(
        files: [VOFile.Entity],
        fixedUser: VOUser.Entity? = nil,
        defaultPermission: VOPermission.Value? = nil
    ) {
        self.files = files
        self.fixedUser = fixedUser
        self.defaultPermission = defaultPermission
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
                .disabled(fixedUser != nil)
                Picker("Permission", selection: $permission) {
                    Text("Viewer").tag(VOPermission.Value.viewer)
                    Text("Editor").tag(VOPermission.Value.editor)
                    Text("Owner").tag(VOPermission.Value.owner)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("User Permission")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isProcessing {
                    ProgressView()
                } else {
                    Button("Apply") {
                        performGrant()
                    }
                    .disabled(!isValid())
                }
            }
        }
        .onAppear {
            if let fixedUser {
                user = fixedUser
            }
            if let defaultPermission {
                permission = defaultPermission
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
    }

    private func performGrant() {
        guard let user, let permission else { return }
        isProcessing = true
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
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        user != nil && permission != nil
    }
}
