import SwiftUI
import VoltaserveCore

struct SharingGroupPermission: View {
    @EnvironmentObject private var sharingStore: SharingStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let files: [VOFile.Entity]
    private let fixedGroup: VOGroup.Entity?
    private let defaultPermission: VOPermission.Value?
    private let showCancel: Bool

    init(
        files: [VOFile.Entity],
        fixedGroup: VOGroup.Entity? = nil,
        defaultPermission: VOPermission.Value? = nil,
        showCancel: Bool = false
    ) {
        self.files = files
        self.fixedGroup = fixedGroup
        self.defaultPermission = defaultPermission
        self.showCancel = showCancel
    }

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    if let workspace = workspaceStore.current {
                        GroupSelector(organizationID: workspace.organization.id) { group in
                            self.group = group
                        }
                    }
                } label: {
                    HStack {
                        Text("Group")
                        if let group {
                            Spacer()
                            Text(group.name)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(fixedGroup != nil)
                Picker("Permission", selection: $permission) {
                    Text("Viewer").tag(VOPermission.Value.viewer)
                    Text("Editor").tag(VOPermission.Value.editor)
                    Text("Owner").tag(VOPermission.Value.owner)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Group Permission")
        .toolbar {
            if showCancel {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
            if let fixedGroup {
                group = fixedGroup
            }
            if let defaultPermission {
                permission = defaultPermission
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
    }

    private func performGrant() {
        guard let group, let permission else { return }
        isProcessing = true
        withErrorHandling {
            for file in files {
                try await sharingStore.grantGroupPermission(id: file.id, groupID: group.id, permission: permission)
            }
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Granting Group Permission"
            errorMessage = message
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        group != nil && permission != nil
    }
}
