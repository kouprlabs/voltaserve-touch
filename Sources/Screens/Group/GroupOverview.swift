import SwiftUI
import VoltaserveCore

struct GroupOverview: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
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
                            GroupMembers()
                                .navigationTitle("Members")
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            GroupSettings {
                                presentationMode.wrappedValue.dismiss()
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

#Preview {
    GroupOverview(VOGroup.Entity.devInstance)
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(GroupStore(VOGroup.Entity.devInstance))
}
