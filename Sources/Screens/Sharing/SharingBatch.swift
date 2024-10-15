import SwiftUI
import VoltaserveCore

struct SharingBatch: View {
    @StateObject private var sharingStore = SharingStore()
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Tag = .users
    @State private var user: VOUser.Entity?
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let fileIDs: [String]

    init(_ files: [String], workspaceStore: WorkspaceStore) {
        fileIDs = files
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Users", systemImage: "person", value: Tag.users) {
                NavigationStack {
                    SharingUserPermission(
                        fileIDs: fileIDs,
                        sharingStore: sharingStore,
                        workspaceStore: workspaceStore,
                        enableCancel: true
                    )
                }
            }
            Tab("Groups", systemImage: "person.2", value: Tag.groups) {
                NavigationStack {
                    SharingGroupPermission(
                        fileIDs: fileIDs,
                        sharingStore: sharingStore,
                        workspaceStore: workspaceStore,
                        enableCancel: true
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Sharing")
    }

    enum Tag {
        case users
        case groups
    }
}
