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

struct VOErrorAlert: ViewModifier {
    @EnvironmentObject private var tokenStore: TokenStore
    private let isPresented: Binding<Bool>
    private let title: String?
    private let message: String?

    init(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil) {
        self.isPresented = isPresented
        self.title = title
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .alert(title ?? "Error", isPresented: isPresented) {
                Button("Sign Out", role: .destructive) {
                    tokenStore.token = nil
                    tokenStore.deleteFromKeychain()
                }
            } message: {
                Text(message ?? "Unexpected error occurred.")
            }
    }
}

extension View {
    func voErrorAlert(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil)
        -> some View
    {
        modifier(VOErrorAlert(isPresented: isPresented, title: title, message: message))
    }
}
