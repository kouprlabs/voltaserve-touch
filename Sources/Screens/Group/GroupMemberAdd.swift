import SwiftUI
import VoltaserveCore

struct GroupMemberAdd: View {
    @EnvironmentObject private var groupStore: GroupStore
    @State private var user: VOUser.Entity?
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let onCompletion: (() -> Void)?

    init(onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        UserSelector { user in
                            self.user = user
                        }
                    } label: {
                        HStack {
                            Text("Select User")
                            if let user {
                                Spacer()
                                Text(user.fullName)
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
                        onCompletion?()
                    }
                }
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
        }
    }

    private func performSave() {
        guard let user else { return }

        isSaving = true

        VOErrorResponse.withErrorHandling {
            try await groupStore.addMember(user.id)
            return true
        } success: {
            onCompletion?()
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
