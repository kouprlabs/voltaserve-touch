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

@Model
public class Server: Codable {
    public var id: String
    public var name: String
    public var apiURL: String
    public var idpURL: String
    public var signInStrategy: String
    public var isActive: Bool

    public var signInStrategyEnum: SignInStrategy {
        SignInStrategy(rawValue: signInStrategy)!
    }

    public init(id: String, name: String, apiURL: String, idpURL: String, signInStrategy: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.apiURL = apiURL
        self.idpURL = idpURL
        self.signInStrategy = signInStrategy
        self.isActive = isActive
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        apiURL = try container.decode(String.self, forKey: .apiURL)
        idpURL = try container.decode(String.self, forKey: .idpURL)
        signInStrategy = try container.decode(String.self, forKey: .signInStrategy)
        isActive = try container.decode(Bool.self, forKey: .isActive)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(apiURL, forKey: .apiURL)
        try container.encode(idpURL, forKey: .idpURL)
        try container.encode(signInStrategy, forKey: .signInStrategy)
        try container.encode(isActive, forKey: .isActive)
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case apiURL
        case idpURL
        case signInStrategy
        case isActive
    }

    func isLocalSignIn() -> Bool {
        signInStrategy == SignInStrategy.local.rawValue
    }

    func isAppleSignIn() -> Bool {
        signInStrategy == SignInStrategy.apple.rawValue
    }
}
