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
import SwiftData

public struct Config {
    public var apiURL: String
    public var idpURL: String
    public var signInStrategy: SignInStrategy

    private static let fallbackConfig = Config(
        apiURL: "http://localhost:8080",
        idpURL: "http://localhost:8081",
        signInStrategy: .local
    )

    public static let shared: Config = {
        guard let container = try? ModelContainer(for: Server.self) else {
            return fallbackConfig
        }
        guard
            let server = try? ModelContext(container)
                .fetch(FetchDescriptor<Server>())
                .first(where: { $0.isActive })
        else {
            return fallbackConfig
        }

        return Config(
            apiURL: server.apiURL,
            idpURL: server.idpURL,
            signInStrategy: SignInStrategy(rawValue: server.signInStrategy)!
        )
    }()

    func isLocalSignIn() -> Bool {
        signInStrategy == .local
    }

    func isAppleSignIn() -> Bool {
        signInStrategy == .apple
    }
}
