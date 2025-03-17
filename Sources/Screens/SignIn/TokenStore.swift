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
import Foundation

@MainActor
public class TokenStore: ObservableObject {
    @Published public var token: VOToken.Value?
    private var client = createClient()

    public init() {}

    private static func createClient() -> VOToken {
        VOToken(baseURL: Config.shared.idpURL)
    }

    public func recreateClient() {
        client = TokenStore.createClient()
    }

    public func signIn(username: String, password: String) async throws -> VOToken.Value {
        try await client.exchange(
            .init(
                grantType: .password,
                username: username,
                password: password
            ))
    }

    public func refreshTokenIfNecessary() async throws -> VOToken.Value? {
        guard token != nil else { return nil }
        if let token, token.isExpired {
            if let newToken = try? await client.exchange(
                .init(
                    grantType: .refreshToken,
                    refreshToken: token.refreshToken
                ))
            {
                return newToken
            }
        }
        return nil
    }

    public func loadFromKeyChain() -> VOToken.Value? {
        KeychainManager.standard.getToken(KeychainManager.Constants.tokenKey)
    }

    public func saveInKeychain(_ token: VOToken.Value) {
        KeychainManager.standard.saveToken(token, forKey: KeychainManager.Constants.tokenKey)
    }

    public func deleteFromKeychain() {
        KeychainManager.standard.delete(KeychainManager.Constants.tokenKey)
    }
}

extension VOToken.Value {
    public var isExpired: Bool {
        Int(Date().timeIntervalSince1970) >= expiresIn
    }
}
