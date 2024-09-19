import SwiftUI

struct FileDelete: View {
    @State private var isProcessing = false
    private let ids: Set<String>
    private let onCompletion: (() -> Void)?

    init(_ ids: Set<String>, onCompletion: (() -> Void)? = nil) {
        self.ids = ids
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationView {
            VStack {
                if isProcessing {
                    ProgressView()
                    Text(
                        ids.count == 1 ?
                            "Deleting item." :
                            "Deleting \(ids.count) item(s)."
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
