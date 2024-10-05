import Foundation
import SwiftUI
import VoltaserveCore

struct BrowserOverview: View {
    @Environment(\.dismiss) private var dismiss
    private let id: String
    private let workspace: VOWorkspace.Entity
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?

    init(
        _ id: String,
        workspace: VOWorkspace.Entity,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)?
    ) {
        self.id = id
        self.workspace = workspace
        self.onCompletion = onCompletion
        self.confirmLabelText = confirmLabelText
    }

    var body: some View {
        NavigationStack {
            BrowserList(
                workspace.rootID,
                workspace: workspace,
                confirmLabelText: confirmLabelText
            ) { id in
                onCompletion?(id)
                dismiss()
            } onDismiss: {
                dismiss()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(workspace.name)
        }
    }
}
