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

extension String {
    func hasMinLength(_ count: Int) -> Bool {
        self.count >= count
    }

    func hasMinLowerCase(_ count: Int) -> Bool {
        self.filter { $0.isLowercase }.count >= count
    }

    func hasMinUpperCase(_ count: Int) -> Bool {
        self.filter { $0.isUppercase }.count >= count
    }

    func hasMinNumbers(_ count: Int) -> Bool {
        self.filter { $0.isNumber }.count >= count
    }

    func hasMinSymbols(_ count: Int) -> Bool {
        let symbolsSet = CharacterSet.alphanumerics.union(.whitespaces).inverted
        let symbolsCount = self.unicodeScalars.filter { symbolsSet.contains($0) }.count
        return symbolsCount >= count
    }
}
