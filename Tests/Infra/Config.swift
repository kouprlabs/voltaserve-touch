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
import VoltaserveCore

struct Config {
    let apiURL = "http://\(ProcessInfo.processInfo.environment["API_HOST"] ?? "localhost"):8080"
    let idpURL = "http://\(ProcessInfo.processInfo.environment["IDP_HOST"] ?? "localhost"):8081"
    let username = ProcessInfo.processInfo.environment["USERNAME"] ?? "test@koupr.com"
    let password = ProcessInfo.processInfo.environment["PASSWORD"] ?? "Passw0rd!"
    let otherUsername = ProcessInfo.processInfo.environment["OTHER_USERNAME"] ?? "test+1@koupr.com"
    let otherPassword = ProcessInfo.processInfo.environment["OTHER_PASSWORD"] ?? "Passw0rd!"

    var credentials: Credentials {
        .init(username: username, password: password)
    }

    var otherCredentials: Credentials {
        .init(username: otherUsername, password: otherPassword)
    }

    struct Credentials {
        let username: String
        let password: String
    }
}
