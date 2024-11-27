// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import SwiftData
import SwiftUI
import VoltaserveCore

struct ContentView: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.modelContext) private var context
    @Query private var servers: [Server]
    @State private var timer: Timer?
    @State private var signInIsPresented = false

    var body: some View {
        MainView()
            .onAppear {
                if let token = tokenStore.loadFromKeyChain() {
                    if token.isExpired {
                        tokenStore.token = nil
                        tokenStore.deleteFromKeychain()
                        signInIsPresented = true
                    } else {
                        tokenStore.token = token
                    }
                } else {
                    signInIsPresented = true
                }

                startTokenTimer()

                if !servers.contains(where: \.isCloud) {
                    context.insert(Server.cloud)
                }
                if UserDefaults.standard.server == nil {
                    UserDefaults.standard.server = Server.cloud
                }
            }
            .onDisappear { stopTokenTimer() }
            .onChange(of: tokenStore.token) { oldToken, newToken in
                if oldToken != nil, newToken == nil {
                    stopTokenTimer()
                    // This is hack to mitigate a SwiftUI bug that causes `fullScreenCover` to dismiss
                    // itself unexpectedly without user interaction or a direct code-triggered dismissal.
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        DispatchQueue.main.async {
                            signInIsPresented = true
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $signInIsPresented) {
                SignIn {
                    startTokenTimer()
                    signInIsPresented = false
                }
            }
    }

    private func startTokenTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard tokenStore.token != nil else { return }
            if let token = tokenStore.token, token.isExpired {
                Task {
                    if let newToken = try await tokenStore.refreshTokenIfNecessary() {
                        DispatchQueue.main.async {
                            tokenStore.token = newToken
                            tokenStore.saveInKeychain(newToken)
                        }
                    }
                }
            }
        }
    }

    private func stopTokenTimer() {
        timer?.invalidate()
        timer = nil
    }
}
