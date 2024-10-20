import SwiftUI
import VoltaserveCore

struct GroupEditName: View {
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let onCompletion: ((VOGroup.Entity) -> Void)?

    init(groupStore: GroupStore, onCompletion: ((VOGroup.Entity) -> Void)? = nil) {
        self.groupStore = groupStore
        self.onCompletion = onCompletion
    }

    var body: some View {
        if let current = groupStore.current {
            Form {
                TextField("Name", text: $value)
                    .disabled(isSaving)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Change Name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performSave()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                value = current.name
            }
            .onChange(of: groupStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.name
                }
            }
        } else {
            ProgressView()
        }
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        guard let current = groupStore.current else { return }
        isSaving = true
        var updatedGroup: VOGroup.Entity?

        withErrorHandling {
            updatedGroup = try await groupStore.patchName(current.id, name: value)
            return true
        } success: {
            dismiss()
            if let onCompletion, let updatedGroup {
                onCompletion(updatedGroup)
            }
        } failure: { message in
            errorTitle = "Error: Saving Name"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let current = groupStore.current {
            return !normalizedValue.isEmpty && normalizedValue != current.name
        }
        return false
    }
}
