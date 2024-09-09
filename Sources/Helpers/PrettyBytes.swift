import Foundation

extension Int {
    func prettyBytes() -> String {
        let UNITS = ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]

        let isNegative = self < 0
        let value = abs(self)

        if value < 1 {
            return (isNegative ? "-" : "") + "\(value) B"
        }

        // Properly calculate the exponent ensuring the correct use of log10 and Swift's global min function
        let doubleValue = Double(value)
        let exponent = Swift.min(Int(log10(doubleValue) / log10(1000.0)), UNITS.count - 1)
        let number = doubleValue / pow(1000, Double(exponent))
        let roundedNumber = number.toPrecision(3)
        let unit = UNITS[exponent]

        return (isNegative ? "-" : "") + "\(roundedNumber) \(unit)"
    }
}

extension Double {
    func toPrecision(_ precision: Int) -> String {
        String(format: "%.\(precision)g", self)
    }
}
