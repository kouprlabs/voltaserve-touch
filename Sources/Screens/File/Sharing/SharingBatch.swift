import SwiftUI
import VoltaserveCore

struct SharingBatch: View {
    @StateObject private var sharingStore = SharingStore()
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Tag = .users
    @State private var user: VOUser.Entity?
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let files: [VOFile.Entity]

    init(_ files: [VOFile.Entity]) {
        self.files = files
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Users", systemImage: "person", value: Tag.users) {
                NavigationStack {
                    SharingUserPermission(files: files, showCancel: true)
                }
            }
            Tab("Groups", systemImage: "person.2", value: Tag.groups) {
                NavigationStack {
                    SharingGroupPermission(files: files, showCancel: true)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Sharing")
        .environmentObject(sharingStore)
    }

    enum Tag {
        case users
        case groups
    }
}
