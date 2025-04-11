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

public struct SignIn: View {
    private let extensions: () -> AnyView
    private let onCompletion: (() -> Void)?

    public init(
        @ViewBuilder extensions: @escaping () -> AnyView = { AnyView(EmptyView()) },
        onCompletion: (() -> Void)? = nil
    ) {
        self.extensions = extensions
        self.onCompletion = onCompletion
    }

    public var body: some View {
        if Config.shared.isLocalStrategy() {
            SignInWithLocal(extensions: extensions, onCompletion: onCompletion)
        } else if Config.shared.isAppleStrategy() {
            SignInWithApple(extensions: extensions, onCompletion: onCompletion)
        }
    }
}

#Preview {
    SignIn()
}
