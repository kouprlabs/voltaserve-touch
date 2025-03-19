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

extension Int {
    public func prettyBytes() -> String {
        let units = ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]

        let isNegative = self < 0
        let value = abs(self)

        if value < 1 {
            return (isNegative ? "-" : "") + "\(value) B"
        }

        // Properly calculate the exponent ensuring the correct use of log10 and Swift's global min function
        let doubleValue = Double(value)
        let exponent = Swift.min(Int(log10(doubleValue) / log10(1000.0)), units.count - 1)
        let number = doubleValue / pow(1000, Double(exponent))
        let roundedNumber = number.toPrecision(3)
        let unit = units[exponent]

        return (isNegative ? "-" : "") + "\(roundedNumber) \(unit)"
    }
}

extension Double {
    public func toPrecision(_ precision: Int) -> String {
        String(format: "%.\(precision)g", self)
    }
}
