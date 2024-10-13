import SwiftUI
import VoltaserveCore

struct MosaicCreate: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isCreating = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        Form {
            Section {
                Text("Create a mosaic to enhance view performance of a large image by splitting it into smaller, manageable tiles. This makes browsing a high-resolution image faster and more efficient.")
            }
            Section {
                Button {} label: {
                    HStack {
                        Text("Create Mosaic")
                        if isCreating {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Mosaic")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .disabled(isCreating)
            }
        }
    }
}
