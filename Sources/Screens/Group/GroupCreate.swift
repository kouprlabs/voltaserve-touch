import SwiftUI
import VoltaserveCore

struct GroupCreate: View {
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    @State private var organization: VOOrganization.Entity?
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private var onCompletion: ((VOGroup.Entity?) -> Void)?

    init(groupStore: GroupStore, onCompletion: ((VOGroup.Entity?) -> Void)? = nil) {
        self.groupStore = groupStore
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .disabled(isProcessing)
                NavigationLink {
                    OrganizationSelector { organization in
                        self.organization = organization
                    }
                    .disabled(isProcessing)
                } label: {
                    HStack {
                        Text("Organization")
                        if let organization {
                            Spacer()
                            Text(organization.name)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Create") {
                            performCreate()
                        }
                        .disabled(!isValid())
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        }
    }

    private var normalizedName: String {
        name.lowercased().trimmingCharacters(in: .whitespaces)
    }

    private func performCreate() {
        guard let organization else { return }
        isProcessing = true
        var group: VOGroup.Entity?

        withErrorHandling {
            group = try await groupStore.create(name: normalizedName, organization: organization)
            return true
        } success: {
            dismiss()
            if let onCompletion, let group {
                onCompletion(group)
            }
        } failure: { message in
            errorTitle = "Error: Crearing Group"
            errorMessage = message
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        !normalizedName.isEmpty && organization != nil
    }
}
