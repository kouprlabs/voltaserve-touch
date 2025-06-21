// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Foundation
import SwiftUI
import VoltaserveCore

public struct InvitationCreate: View, FormValidatable, SessionDistributing, ErrorPresentable {
    @EnvironmentObject private var sessionStore: SessionStore
    @ObservedObject private var invitationStore: InvitationStore
    @Environment(\.dismiss) private var dismiss
    @State private var commaSeparated = ""
    @State private var emails: [String] = []
    @State private var isProcessing = false
    private let organizationID: String

    public init(_ organizationID: String, invitationStore: InvitationStore) {
        self.organizationID = organizationID
        self.invitationStore = invitationStore
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: VOSectionHeader("Comma separated emails")) {
                    TextEditor(text: $commaSeparated)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .disabled(isProcessing)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isProcessing {
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
        .onAppear {
            invitationStore.organizationID = organizationID
            if let session = sessionStore.session {
                assignSessionToStores(session)
            }
        }
        .onChange(of: sessionStore.session) { _, newSession in
            if let newSession {
                assignSessionToStores(newSession)
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
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
        guard let organizationID = invitationStore.organizationID else { return }
        withErrorHandling {
            let invitations = try await invitationStore.create(
                .init(organizationID: organizationID, emails: emails)
            )
            if let invitations, !invitations.isEmpty {
                try await invitationStore.syncEntities()
            }
            if invitationStore.isLastPage() {
                invitationStore.fetchNextPage()
            }
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented = false
    @State public var errorMessage: String?

    // MARK: - FormValidatable

    public func isValid() -> Bool {
        !emails.isEmpty
    }

    // MARK: - SessionDistributing

    public func assignSessionToStores(_ session: VOSession.Value) {
        invitationStore.session = session
    }
}
