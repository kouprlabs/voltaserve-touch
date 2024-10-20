import SwiftData
import SwiftUI

struct ServerList: View {
    @Environment(\.modelContext) private var context
    @Query private var servers: [Server]
    @State private var showCreate = false

    var body: some View {
        List(servers, id: \.id) { server in
            NavigationLink {
                ServerOverview(server)
            } label: {
                ServerRow(server)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Servers")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: ServerCreate()) {
                    Label("New Server", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    ServerList()
}
