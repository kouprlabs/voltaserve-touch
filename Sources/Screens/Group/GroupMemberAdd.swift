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

public struct GroupMemberAdd: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var groupStore: GroupStore
    @ObservedObject private var userStore: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var user: VOUser.Entity?
    @State private var isProcessing = false

    public init(groupStore: GroupStore, userStore: UserStore) {
        self.groupStore = groupStore
        self.userStore = userStore
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        if let group = groupStore.current {
                            UserSelector(
                                organizationID: group.organization.id, groupID: group.id, excludeGroupMembers: true
                            ) { user in
                                self.user = user
                            }
                        }
                    } label: {
                        HStack {
                            Text("User")
                            if let user {
                                Spacer()
                                Text(user.fullName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Add Member")
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
                        Button("Add") {
                            performAdd()
                        }
                        .disabled(!isValid())
                    }
                }
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performAdd() {
        guard let user else { return }
        guard let current = groupStore.current else { return }

        withErrorHandling {
            try await groupStore.addMember(current.id, options: .init(userID: user.id))
            try await userStore.syncEntities()
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
        user != nil
    }
}
