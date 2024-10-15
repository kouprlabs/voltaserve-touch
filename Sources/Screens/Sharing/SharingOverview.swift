import SwiftUI
import VoltaserveCore

struct SharingOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var sharingStore = SharingStore()
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Tag = .users
    @State private var user: VOUser.Entity?
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    @State private var userPermissionCount = 0
    @State private var groupPermissionCount = 0
    private let fileID: String

    init(_ fileID: String, workspaceStore: WorkspaceStore) {
        self.fileID = fileID
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                Tab("Users", systemImage: "person", value: Tag.users) {
                    SharingUserList(
                        fileID,
                        sharingStore: sharingStore,
                        workspaceStore: workspaceStore
                    )
                }
                .badge(userPermissionCount)
                Tab("Groups", systemImage: "person.2", value: Tag.groups) {
                    SharingGroupList(
                        fileID,
                        sharingStore: sharingStore,
                        workspaceStore: workspaceStore
                    )
                }
                .badge(groupPermissionCount)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Sharing")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        if selection == .users {
                            SharingUserPermission(
                                fileIDs: [fileID],
                                sharingStore: sharingStore,
                                workspaceStore: workspaceStore
                            )
                        } else if selection == .groups {
                            SharingGroupPermission(
                                fileIDs: [fileID],
                                sharingStore: sharingStore,
                                workspaceStore: workspaceStore
                            )
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                sharingStore.fileID = fileID
                if let token = tokenStore.token {
                    assignTokenToStores(token)
                    startTimers()
                    onAppearOrChange()
                }
            }
            .onDisappear {
                stopTimers()
            }
            .onChange(of: sharingStore.token) { _, newToken in
                if let newToken {
                    assignTokenToStores(newToken)
                    onAppearOrChange()
                }
            }
            .onChange(of: sharingStore.userPermissions) { _, newUserPermissions in
                if let newUserPermissions, newUserPermissions.count > 0 {
                    userPermissionCount = newUserPermissions.count
                } else {
                    userPermissionCount = 0
                }
            }
            .onChange(of: sharingStore.groupPermissions) { _, newGroupPermissions in
                if let newGroupPermissions, newGroupPermissions.count > 0 {
                    groupPermissionCount = newGroupPermissions.count
                } else {
                    groupPermissionCount = 0
                }
            }
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        sharingStore.fetchUserPermissions()
        sharingStore.fetchGroupPermissions()
    }

    private func startTimers() {
        sharingStore.startTimer()
    }

    private func stopTimers() {
        sharingStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        sharingStore.token = token
    }

    enum Tag {
        case users
        case groups
    }
}
