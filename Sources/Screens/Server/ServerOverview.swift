import SwiftData
import SwiftUI

struct ServerOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var servers: [Server]
    @State private var showActivateConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var isActivating = false
    @State private var isDeleting = false
    private let server: Server

    init(_ server: Server) {
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
            Section {
                Button {
                    showActivateConfirmation = true
                } label: {
                    HStack {
                        Text("Activate Server")
                        if isActivating {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(server.isActive || isProcessing)
                .confirmationDialog("Activate Server", isPresented: $showActivateConfirmation) {
                    Button("Activate") {
                        performActivate()
                    }
                } message: {
                    Text("Are you sure you want to activate this server?")
                }
                if !server.isCloud {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Text("Delete Server")
                            if isDeleting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing)
                    .confirmationDialog("Delete Server", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            performDelete()
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

    private var isProcessing: Bool {
        isDeleting || isActivating
    }

    private func performActivate() {
        isActivating = true
        Task {
            servers.filter { $0.id != server.id }.forEach { $0.isActive = false }
            servers.first(where: { $0.id == server.id })?.isActive = true
            try? context.save()

            UserDefaults.standard.server = server
            tokenStore.recreateClient()

            DispatchQueue.main.async {
                isActivating = false
                dismiss()
            }
        }
    }

    private func performDelete() {
        isDeleting = true
        Task {
            let id = server.id
            if server.isActive {
                servers.first(where: { $0.id == Server.cloud.id })?.isActive = true
            }
            try? context.delete(model: Server.self, where: #Predicate { $0.id == id })
            try? context.save()
            DispatchQueue.main.async {
                isDeleting = false
                dismiss()
            }
        }
    }
}

#Preview {
    ServerOverview(Server(
        id: UUID().uuidString,
        name: "Local",
        apiURL: "http://localhost:8080",
        idpURL: "http://localhost:8081",
        isCloud: false,
        isActive: true
    ))
}
