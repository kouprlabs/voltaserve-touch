import SwiftUI
import VoltaserveCore

struct GroupOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    private let group: VOGroup.Entity

    init(_ group: VOGroup.Entity) {
        self.group = group
    }

    var body: some View {
        VStack {
            if let current = groupStore.current {
                VStack {
                    VOAvatar(name: current.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            GroupMemberList()
                                .navigationTitle("Members")
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            GroupSettings {
                                dismiss()
                            }
                            .navigationTitle("Settings")
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            groupStore.current = group
        }
    }
}
