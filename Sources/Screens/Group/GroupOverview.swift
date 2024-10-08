import SwiftUI
import VoltaserveCore

struct GroupOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    private let group: VOGroup.Entity

    init(_ group: VOGroup.Entity, groupStore: GroupStore) {
        self.group = group
        self.groupStore = groupStore
    }

    var body: some View {
        VStack {
            if let current = groupStore.current {
                VStack {
                    VOAvatar(name: current.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            GroupMemberList(groupStore: groupStore)
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            GroupSettings(groupStore: groupStore) {
                                dismiss()
                            }
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(group.name)
        .onAppear {
            groupStore.current = group
        }
    }
}
