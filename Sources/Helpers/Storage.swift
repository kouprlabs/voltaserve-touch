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
