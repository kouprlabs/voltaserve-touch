import SwiftUI

struct FileDelete: View {
    @State private var isProcessing = false
    private let selection: Set<String>
    private let onCompletion: (() -> Void)?

    init(_ selection: Set<String>, onCompletion: (() -> Void)? = nil) {
        self.selection = selection
        self.onCompletion = onCompletion
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
                performDelete()
            }
        }
    }

    private func performDelete() {
        isProcessing = true
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            Task { @MainActor in
                onCompletion?()
                isProcessing = false
            }
        }
    }
}
