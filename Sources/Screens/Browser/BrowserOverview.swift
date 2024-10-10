import Foundation
import SwiftUI
import VoltaserveCore

struct BrowserOverview: View {
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?

    init(
        workspaceStore: WorkspaceStore,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)?
    ) {
        self.workspaceStore = workspaceStore
        self.onCompletion = onCompletion
        self.confirmLabelText = confirmLabelText
    }

    var body: some View {
        if let workspace = workspaceStore.current {
            NavigationStack {
                BrowserList(
                    workspace.rootID,
                    workspaceStore: workspaceStore,
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
}
