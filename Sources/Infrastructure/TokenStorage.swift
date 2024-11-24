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

extension KeychainManager {
    func saveToken(_ token: VOToken.Value, forKey key: String) {
        if let data = try? JSONEncoder().encode(token),
            let serialized = String(data: data, encoding: .utf8)
        {
            saveString(serialized, for: key)
        }
    }

    func getToken(_ key: String) -> VOToken.Value? {
        if let value = getString(key), let data = value.data(using: .utf8) {
            return try? JSONDecoder().decode(VOToken.Value.self, from: data)
        }
        return nil
    }

    enum Constants {
        static let tokenKey = "com.voltaserve.token"
    }
}
