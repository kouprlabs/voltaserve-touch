import SwiftUI

struct ServerList: View {
    @EnvironmentObject private var serverStore: ServerStore
    @State private var showNew = false
    @State private var showActivate = false
    @State private var selectedServer: ServerStore.Entity?

    var body: some View {
        List {
            ForEach(serverStore.entities, id: \.id) { server in
                ServerRow(server) {
                    selectedServer = server
                    showActivate = true
                } onDeletion: {
                    serverStore.delete(server.id)
                }
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
            if serverStore.entities.count > 1 {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .alert("Activate Server", isPresented: $showActivate) {
            Button("Activate") {
                if let selectedServer {
                    serverStore.activate(selectedServer.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let selectedServer {
                Text("Are you sure you want to activate \"\(selectedServer.name)\"?")
            }
        }
    }
}

#Preview {
    ServerList()
}
