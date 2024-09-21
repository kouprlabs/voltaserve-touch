import SwiftUI
import VoltaserveCore

struct GroupSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var onCompletion: (() -> Void)?

    init(_ onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    var body: some View {
        if let group = groupStore.current {
            Form {
                Section(header: VOSectionHeader("Basics")) {
                    NavigationLink(destination: GroupEditName()) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(group.name)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(isDeleting)
                }
                Section(header: VOSectionHeader("Advanced")) {
                    Button(role: .destructive) {
                        showDelete = true
                    } label: {
                        HStack {
                            Text("Delete Group")
                            if isDeleting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            .alert("Delete Group", isPresented: $showDelete) {
                Button("Delete Permanently", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this group?")
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        } else {
            ProgressView()
        }
    }

    private func performDelete() {
        guard let current = groupStore.current else { return }

        isDeleting = true

        VOErrorResponse.withErrorHandling {
            try await groupStore.delete(current.id)
            return true
        } success: {
            dismiss()
            onCompletion?()
        } failure: { message in
            errorTitle = "Error: Deleting Group"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }
}
