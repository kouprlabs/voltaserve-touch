import Foundation
import SwiftUI
import VoltaserveCore

struct InvitationCreate: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @Environment(\.dismiss) private var dismiss
    @State private var commaSeparated = ""
    @State private var emails: [String] = []
    @State private var isSending = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let organizationID: String

    init(_ organizationID: String) {
        self.organizationID = organizationID
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: VOSectionHeader("Comma separated emails")) {
                    TextEditor(text: $commaSeparated)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .disabled(isSending)
                        .onChange(of: commaSeparated) {
                            parseEmails()
                        }
                    Text("Example: alice@example.com, david@example.com")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !emails.isEmpty {
                    Section(header: VOSectionHeader("Valid emails")) {
                        List(emails, id: \.self) { email in
                            Text(email)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Invitations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isSending {
                        ProgressView()
                    } else {
                        Button("Send") {
                            performCreate()
                        }
                        .disabled(!isValid())
                    }
                }
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .onAppear {
            invitationStore.organizationID = organizationID
            if let token = tokenStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        invitationStore.token = token
    }

    private func parseEmails() {
        var values: [String] = []
        for item in commaSeparated.split(separator: ",") {
            let email = item.trimmingCharacters(in: .whitespacesAndNewlines)
            if email.isEmail() {
                values.append(email)
            }
        }
        emails = Array(Set(values)).sorted()
    }

    private func performCreate() {
        isSending = true
        withErrorHandling {
            _ = try await invitationStore.create(emails: emails)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Sending Invitation"
            errorMessage = message
            showError = true
        } anyways: {
            isSending = false
        }
    }

    private func isValid() -> Bool {
        !emails.isEmpty
    }
}
