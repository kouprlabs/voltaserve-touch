import SwiftUI
import VoltaserveCore

struct MosaicOverview: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            if let snapshot = file.snapshot, snapshot.hasMosaic() {
                MosaicSettings(file)
            } else {
                MosaicCreate(file)
            }
        }
    }
}
