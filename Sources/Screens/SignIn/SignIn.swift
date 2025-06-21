// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftData
import SwiftUI
import VoltaserveCore

public struct SignIn: View {
    @Query(filter: #Predicate<Server> { $0.isActive == true }) private var servers: [Server]
    private let extensions: () -> AnyView
    private let onCompletion: (() -> Void)?

    private var activeServer: Server? {
        servers.first
    }

    public init(
        @ViewBuilder extensions: @escaping () -> AnyView = { AnyView(EmptyView()) },
        onCompletion: (() -> Void)? = nil
    ) {
        self.extensions = extensions
        self.onCompletion = onCompletion
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let activeServer {
                    if activeServer.isLocalSignIn() {
                        SignInWithLocal(extensions: extensions, onCompletion: onCompletion)
                    } else if activeServer.isAppleSignIn() {
                        SignInWithApple(extensions: extensions, onCompletion: onCompletion)
                    }
                } else {
                    SignInPlaceholder(extensions: extensions)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ServerList()) {
                        Label("Servers", systemImage: "gear")
                    }
                }
            }
        }
    }
}

#Preview {
    SignIn()
}
