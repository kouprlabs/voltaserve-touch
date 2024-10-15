import SwiftUI
import VoltaserveCore

struct SharingGroupPermission: View {
    @ObservedObject private var sharingStore: SharingStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    @State private var isGranting = false
    @State private var isRevoking = false
    @State private var showRevoke = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let fileIDs: [String]
    private let predefinedGroup: VOGroup.Entity?
    private let defaultPermission: VOPermission.Value?
    private let enableCancel: Bool
    private let enableRevoke: Bool

    init(
        fileIDs: [String],
        sharingStore: SharingStore,
        workspaceStore: WorkspaceStore,
        predefinedGroup: VOGroup.Entity? = nil,
        defaultPermission: VOPermission.Value? = nil,
        enableCancel: Bool = false,
        enableRevoke: Bool = false
    ) {
        self.fileIDs = fileIDs
        self.sharingStore = sharingStore
        self.workspaceStore = workspaceStore
        self.predefinedGroup = predefinedGroup
        self.defaultPermission = defaultPermission
        self.enableCancel = enableCancel
        self.enableRevoke = enableRevoke
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
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(predefinedGroup != nil || isProcessing)
                Picker("Permission", selection: $permission) {
                    Text("Viewer").tag(VOPermission.Value.viewer)
                    Text("Editor").tag(VOPermission.Value.editor)
                    Text("Owner").tag(VOPermission.Value.owner)
                }
                .disabled(isProcessing)
            }
            if enableRevoke, fileIDs.count == 1 {
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
                    .confirmationDialog("Revoke Permission", isPresented: $showRevoke, titleVisibility: .visible) {
                        Button("Revoke", role: .destructive) {
                            performRevoke()
                        }
                    } message: {
                        Text("Are you sure you want to revoke this permission?")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Group Permission")
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
            if let predefinedGroup {
                group = predefinedGroup
            }
            if let defaultPermission {
                permission = defaultPermission
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
    }

    private var isProcessing: Bool {
        isGranting || isRevoking
    }

    private func performGrant() {
        guard let group, let permission else { return }
        isGranting = true
        withErrorHandling {
            for fileID in fileIDs {
                try await sharingStore.grantGroupPermission(id: fileID, groupID: group.id, permission: permission)
            }
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Granting Group Permission"
            errorMessage = message
            showError = true
        } anyways: {
            isGranting = false
        }
    }

    private func performRevoke() {
        guard let group, fileIDs.count == 1, let fileID = fileIDs.first else { return }
        isRevoking = true
        withErrorHandling {
            try await sharingStore.revokeGroupPermission(id: fileID, groupID: group.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Revoking Group Permission"
            errorMessage = message
            showError = true
        } anyways: {
            isRevoking = false
        }
    }

    private func isValid() -> Bool {
        group != nil && permission != nil
    }
}
