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

    public static let shared: Config = {
        let container = try! ModelContainer(for: Server.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Server>()
        if let server = try! context.fetch(descriptor).first(where: { $0.isActive == true }) {
            return Config(
                apiURL: server.apiURL,
                idpURL: server.idpURL,
                signInStrategy: SignInStrategy(rawValue: server.signInStrategy)!
            )
        } else {
            return Config(
                apiURL: "http://localhost:8080",
                idpURL: "http://localhost:8081",
                signInStrategy: .local
            )
        }
    }()

    func isLocalSignIn() -> Bool {
        signInStrategy == .local
    }

    func isAppleSignIn() -> Bool {
        signInStrategy == .apple
    }
}
