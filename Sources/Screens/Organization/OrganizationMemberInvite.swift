import Foundation
import SwiftUI
import VoltaserveCore

struct OrganizationMemberInvite: View {
    @EnvironmentObject private var invitationStore: InvitationStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var commaSeparated = ""
    @State private var emails: [String] = []
    @State private var isSending = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
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
        .navigationTitle("Invite Members")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isSending {
                    ProgressView()
                } else {
                    Button("Send") {
                        performSend()
                    }
                    .disabled(!isValid())
                }
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
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

    private func performSend() {
        guard let organization = organizationStore.current else { return }

        isSending = true

        VOErrorResponse.withErrorHandling {
            try await invitationStore.create(organizationID: organization.id, emails: emails)
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
