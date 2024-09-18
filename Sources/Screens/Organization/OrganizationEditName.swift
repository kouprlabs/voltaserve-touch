import SwiftUI
import VoltaserveCore

struct OrganizationEditName: View {
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        if let current = organizationStore.current {
            Form {
                Section(header: VOSectionHeader("Name")) {
                    TextField("Name", text: $value)
                        .disabled(isSaving)
                }
                Section {
                    Button {
                        performSave()
                    } label: {
                        HStack {
                            Text("Save Name")
                            if isSaving {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSaving || !isValid())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Change Name")
                        .font(.headline)
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                value = current.name
            }
            .onChange(of: organizationStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.name
                }
            }
        } else {
            ProgressView()
        }
    }

    private var nornalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        guard let current = organizationStore.current else { return }

        isSaving = true

        VOErrorResponse.withErrorHandling {
            try await organizationStore.patchName(current.id, name: nornalizedValue)
        } success: {
            presentationMode.wrappedValue.dismiss()
        } failure: { message in
            errorTitle = "Error: Saving Name"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let current = organizationStore.current {
            return !nornalizedValue.isEmpty && nornalizedValue != current.name
        }
        return false
    }
}
