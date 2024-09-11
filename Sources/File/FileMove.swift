import SwiftUI
import VoltaserveCore

struct FileMove: View {
    var workspace: VOWorkspace.Entity
    var selection: Set<String>
    @Binding var isProcessing: Bool
    @Binding var isVisible: Bool

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
