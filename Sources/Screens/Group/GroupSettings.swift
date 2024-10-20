import SwiftUI
import VoltaserveCore

struct GroupSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var onCompletion: (() -> Void)?

    init(groupStore: GroupStore, onCompletion: (() -> Void)? = nil) {
        self.groupStore = groupStore
        self.onCompletion = onCompletion
    }

    var body: some View {
        Group {
            if let group = groupStore.current {
                Form {
                    Section(header: VOSectionHeader("Basics")) {
                        NavigationLink {
                            GroupEditName(groupStore: groupStore) { updatedGroup in
                                groupStore.current = updatedGroup
                                if let index = groupStore.entities?.firstIndex(where: { $0.id == updatedGroup.id }) {
                                    groupStore.entities?[index] = updatedGroup
                                }
                            }
                        } label: {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(group.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Advanced")) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
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
                        .confirmationDialog("Delete Group", isPresented: $showDeleteConfirmation) {
                            Button("Delete Permanently", role: .destructive) {
                                performDelete()
                            }
                        } message: {
                            Text("Are you sure you want to delete this group?")
                        }
                    }
                }
                .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Settings")
    }

    private func performDelete() {
        isDeleting = true
        let current = groupStore.current

        withErrorHandling {
            try await groupStore.delete()
            return true
        } success: {
            dismiss()
            if let current {
                reflectDeleteInStore(current.id)
            }
            onCompletion?()
        } failure: { message in
            errorTitle = "Error: Deleting Group"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }

    private func reflectDeleteInStore(_ id: String) {
        groupStore.entities?.removeAll(where: { $0.id == id })
    }
}
