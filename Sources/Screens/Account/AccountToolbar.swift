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

public struct AccountToolbar: ViewModifier {
    @ObservedObject private var accountStore: AccountStore
    @ObservedObject private var invitationStore: InvitationStore
    @State private var overviewIsPresented = false

    public init(accountStore: AccountStore, invitationStore: InvitationStore) {
        self.accountStore = accountStore
        self.invitationStore = invitationStore
    }

    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        accountButton
                            .padding(.trailing, VOMetrics.spacingXs)
                    } else {
                        accountButton
                    }
                }
            }
            .sheet(isPresented: $overviewIsPresented) {
                AccountOverview()
            }
    }

    private var accountButton: some View {
        ZStack {
            Button {
                overviewIsPresented.toggle()
            } label: {
                if let identityUser = accountStore.identityUser {
                    VOAvatar(
                        name: identityUser.fullName,
                        size: 30,
                        url: accountStore.urlForUserPicture(
                            identityUser.id,
                            fileExtension: identityUser.picture?.fileExtension
                        )
                    )
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            if let count = invitationStore.incomingCount, count > 0 {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 14, y: -11)
            }
        }
    }
}

extension View {
    public func accountToolbar(accountStore: AccountStore, invitationStore: InvitationStore) -> some View {
        modifier(AccountToolbar(accountStore: accountStore, invitationStore: invitationStore))
    }
}
