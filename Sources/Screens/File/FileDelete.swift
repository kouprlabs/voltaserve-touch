import SwiftUI

struct FileDelete: View {
    @State private var isProcessing = false
    private let selection: Set<String>
    private let onDismiss: (() -> Void)?

    init(_ selection: Set<String>, onDismiss: (() -> Void)? = nil) {
        self.selection = selection
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationView {
            VStack {
                if isProcessing {
                    ProgressView()
                    Text(
                        selection.count == 1 ?
                            "Deleting item." :
                            "Deleting \(selection.count) item(s)."
                    )
                }
            }
            .onAppear {
                isProcessing = true
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    Task { @MainActor in
                        onDismiss?()
                        isProcessing = false
                    }
                }
            }
        }
    }
}
