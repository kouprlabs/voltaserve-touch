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
            .tb
        } else if self >= Int(1e9) {
            .gb
        } else if self >= Int(1e6) {
            .mb
        } else {
            .b
        }
    }

    func convertFromByte(unit: StorageUnit) -> Int {
        switch unit {
        case .b:
            self
        case .mb:
            byteToMegabyte()
        case .gb:
            byteToGigabyte()
        case .tb:
            byteToTerabyte()
        }
    }

    func normalizeToByte(unit: StorageUnit) -> Int {
        switch unit {
        case .b:
            self
        case .mb:
            megabyteToByte()
        case .gb:
            gigabyteToByte()
        case .tb:
            terabyteToByte()
        }
    }
}

enum StorageUnit: String {
    case b
    case mb
    case gb
    case tb
}
