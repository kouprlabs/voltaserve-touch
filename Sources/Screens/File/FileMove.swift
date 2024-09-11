import SwiftUI
import VoltaserveCore

struct FileMove: View {
    private(set) var workspace: VOWorkspace.Entity
    private(set) var selection: Set<String>
    @State private var isProcessing = false
    @Binding private(set) var isVisible: Bool

    var body: some View {
        NavigationStack {
            BrowserList(
                workspace.rootID,
                onConfirm: {
                    isProcessing = true
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                        Task { @MainActor in
                            isVisible = false
                            isProcessing = false
                        }
                    }
                },
                onDismiss: { isVisible = false },
                isConfirming: $isProcessing,
                confirmationMessage: selection.count == 1 ?
                    "Moving item." :
                    "Moving \(selection.count) item(s)."
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(workspace.name)
        }
    }
}
