import SwiftUI
import VoltaserveCore

struct MosaicSettings: View {
    @Environment(\.dismiss) private var dismiss
    @State private var info: VOMosaic.Info?
    @State private var isCreating = false
    @State private var isDeleting = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        Form {
            Section {
                Text("Create a mosaic for the active snapshot.")
                Button {} label: {
                    HStack {
                        Text("Create Mosaic")
                        if isCreating {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isProcesssing || !canCreate)
            }
            Section {
                Text("Delete mosaic from the active snapshot.")
                Button(role: .destructive) {} label: {
                    HStack {
                        Text("Delete Mosaic")
                        if isDeleting {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isProcesssing || !canDelete)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Mosaic")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .disabled(isProcesssing)
            }
        }
    }

    private var canCreate: Bool {
        if let info {
            return !(file.snapshot?.task?.isPending ?? false) &&
                info.isOutdated &&
                file.permission.ge(.editor)
        }
        return false
    }

    private var canDelete: Bool {
        if let info {
            return !(file.snapshot?.task?.isPending ?? false) &&
                !info.isOutdated &&
                file.permission.ge(.owner)
        }
        return false
    }

    private var isProcesssing: Bool {
        isDeleting || isCreating
    }
}
