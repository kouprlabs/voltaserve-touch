import SwiftUI

struct ServerList: View {
    @EnvironmentObject private var serverStore: ServerStore
    @State private var showNew = false

    var body: some View {
        List(serverStore.entities, id: \.id) { server in
            NavigationLink {
                ServerInfo(server)
            } label: {
                ServerRow(server)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Servers")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: ServerNew()) {
                    Label("New Server", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    ServerList()
}
