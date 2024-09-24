import SwiftUI

struct ServerInfo: View {
    @EnvironmentObject private var serverStore: ServerStore
    @Environment(\.dismiss) private var dismiss
    @State private var showActivateConfirmation = false
    @State private var showDeleteConfirmation = false
    private let server: ServerStore.Entity

    init(_ server: ServerStore.Entity) {
        self.server = server
    }

    var body: some View {
        Form {
            Section(header: VOSectionHeader("API URL")) {
                Text(server.apiURL)
            }
            Section(header: VOSectionHeader("Identity Provider URL")) {
                Text(server.idpURL)
            }
            Section(header: VOSectionHeader("Actions")) {
                Button("Activate Server") {
                    showActivateConfirmation = true
                }
                .disabled(server.isActive)
                .confirmationDialog("Activate Server", isPresented: $showActivateConfirmation) {
                    Button("Activate") {
                        serverStore.activate(server.id)
                    }
                } message: {
                    Text("Are you sure you want to activate this server?")
                }
                if !server.isCloud {
                    Button("Delete Server", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .confirmationDialog("Delete Server", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            serverStore.delete(server.id)
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to delete this server?")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(server.name)
    }
}

#Preview {
    ServerInfo(ServerStore.Entity(
        id: UUID().uuidString,
        name: "Local",
        apiURL: "http://localhost:8080",
        idpURL: "http://localhost:8081",
        isCloud: false,
        isActive: true
    ))
}
