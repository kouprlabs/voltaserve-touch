import Foundation

struct IDRandomizer {
    private var _value: String?
    private var lastValue: String?
    private var ids: [String]

    var value: String {
        if let value = _value {
            value
        } else {
            ids.randomElement()!
        }
    }

    init(_ ids: [String]) {
        self.ids = ids
    }

    mutating func shuffle() {
        var remaining = 1000
        repeat {
            _value = ids.randomElement()
            remaining -= 1
        } while _value == lastValue && remaining > 0
        lastValue = _value
    }
}
