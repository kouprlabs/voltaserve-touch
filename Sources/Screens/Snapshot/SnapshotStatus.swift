import SwiftUI
import VoltaserveCore

struct SnapshotStatus: View {
    private let status: VOSnapshot.Status

    init(_ status: VOSnapshot.Status) {
        self.status = status
    }

    var body: some View {
        Text(text())
    }

    private func text() -> String {
        switch status {
        case .waiting:
            "Waiting"
        case .processing:
            "Processing"
        case .ready:
            "Ready"
        case .error:
            "Error"
        }
    }
}

#Preview {
    SnapshotStatus(.waiting)
    SnapshotStatus(.processing)
    SnapshotStatus(.ready)
    SnapshotStatus(.error)
}
