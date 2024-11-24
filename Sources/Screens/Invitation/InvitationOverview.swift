// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI
import VoltaserveCore

struct InvitationOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var invitationStore: InvitationStore
    @StateObject private var userStore = UserStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation = false
    @State private var showDeclineConfirmation = false
    @State private var isAccepting = false
    @State private var isDeclining = false
    @State private var isDeleting = false
    private let invitation: VOInvitation.Entity
    private let isDeletable: Bool
    private let isAcceptableDeclinable: Bool

    init(
        _ invitation: VOInvitation.Entity,
        invitationStore: InvitationStore,
        isDeletable: Bool = false,
        isAcceptableDeclinable: Bool = false
    ) {
        self.invitation = invitation
        self.invitationStore = invitationStore
        self.isDeletable = isDeletable
        self.isAcceptableDeclinable = isAcceptableDeclinable
    }

    var body: some View {
        Form {
            if let owner = invitation.owner {
                Section(header: VOSectionHeader("Sender")) {
                    UserRow(
                        owner,
                        pictureURL: userStore.urlForPicture(
                            owner.id,
                            fileExtension: owner.picture?.fileExtension
                        )
                    )
                    HStack {
                        Text("When")
                        Spacer()
                        if let date = invitation.createTime.date {
                            Text(date.pretty)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section(header: VOSectionHeader("Receiver")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(invitation.email)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Status")
                    Spacer()
                    InvitationStatusBadge(invitation.status)
                }
            }
            if let organization = invitation.organization {
                Section(header: VOSectionHeader("Organization")) {
                    OrganizationRow(organization)
                }
            }
            Section {
                if isDeletable {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Text("Delete Invitation")
                            if isDeleting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing)
                    .confirmationDialog("Delete Invitation", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            performDelete()
                        }
                    } message: {
                        Text("Are you sure you want to delete this invitation?")
                    }
                }
                if isAcceptableDeclinable {
                    Button {
                        performAccept()
                    } label: {
                        HStack {
                            Text("Accept Invitation")
                            if isAccepting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing)
                    Button(role: .destructive) {
                        showDeclineConfirmation = true
                    } label: {
                        HStack {
                            Text("Decline Invitation")
                            if isDeclining {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing)
                    .confirmationDialog("Decline Invitation", isPresented: $showDeclineConfirmation)
                    {
                        Button("Decline", role: .destructive) {
                            performDecline()
                        }
                    } message: {
                        Text("Are you sure you want to decline this invitation?")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("#\(invitation.id)")
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .onAppear {
            userStore.invitationID = invitation.id
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

    private var isProcessing: Bool {
        isAccepting || isDeclining || isDeleting
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }

    private func performAccept() {
        isAccepting = true
        withErrorHandling {
            try await invitationStore.accept(invitation.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Accepting Invitation"
            errorMessage = message
            showError = true
        } anyways: {
            isAccepting = false
        }
    }

    private func performDecline() {
        isDeclining = true
        withErrorHandling {
            try await invitationStore.decline(invitation.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Declining Invitation"
            errorMessage = message
            showError = true
        } anyways: {
            isDeclining = false
        }
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            try await invitationStore.delete(invitation.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Deleting Invitation"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }
}
