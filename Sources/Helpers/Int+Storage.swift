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
    func byteToMegabyte() -> Int {
        self / Int(1e6)
    }

    func byteToGigabyte() -> Int {
        self / Int(1e9)
    }

    func byteToTerabyte() -> Int {
        self / Int(1e12)
    }

    func terabyteToByte() -> Int {
        self * Int(1e12)
    }

    func gigabyteToByte() -> Int {
        self * Int(1e9)
    }

    func megabyteToByte() -> Int {
        self * Int(1e6)
    }

    var storageUnit: StorageUnit {
        if self >= Int(1e12) {
            .terabyte
        } else if self >= Int(1e9) {
            .gigabyte
        } else if self >= Int(1e6) {
            .megabyte
        } else {
            .byte
        }
    }

    func convertFromByte(to unit: StorageUnit) -> Int {
        switch unit {
        case .byte:
            self
        case .megabyte:
            byteToMegabyte()
        case .gigabyte:
            byteToGigabyte()
        case .terabyte:
            byteToTerabyte()
        }
    }

    func normalizeToByte(from unit: StorageUnit) -> Int {
        switch unit {
        case .byte:
            self
        case .megabyte:
            megabyteToByte()
        case .gigabyte:
            gigabyteToByte()
        case .terabyte:
            terabyteToByte()
        }
    }
}

enum StorageUnit: String {
    case byte
    case megabyte
    case gigabyte
    case terabyte
}
