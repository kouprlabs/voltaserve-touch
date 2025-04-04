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

public struct Config {
    public var apiURL: String
    public var idpURL: String
    public var idpStrategy: IdPStrategy = .local

    public static let shared: Config = {
        guard let localPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: localPath) as? [String: String]
        else {
            fatalError("Failed to load config.")
        }

        return Config(
            apiURL: dict["apiURL"]!,
            idpURL: dict["idpURL"]!,
            idpStrategy: dict["idpStrategy"].flatMap(IdPStrategy.init) ?? .local
        )
    }()

    func isLocalStrategy() -> Bool {
        idpStrategy == .local
    }

    func isAppleStrategy() -> Bool {
        idpStrategy == .apple
    }

    public enum IdPStrategy: String, Codable {
        case local
        case apple
    }
}
