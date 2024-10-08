import SwiftUI
import VoltaserveCore

struct GroupMemberAdd: View {
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var user: VOUser.Entity?
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    init(groupStore: GroupStore) {
        self.groupStore = groupStore
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        if let group = groupStore.current {
                            UserSelector(groupID: group.id) { user in
                                self.user = user
                            }
                        }
                    } label: {
                        HStack {
                            Text("User")
                            if let user {
                                Spacer()
                                Text(user.fullName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Add Member")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Add") {
                            performAdd()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        }
    }

    private func performAdd() {
        guard let user else { return }
        isSaving = true

        withErrorHandling {
            try await groupStore.addMember(user.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Adding Member"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        user != nil
    }
}
