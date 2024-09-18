import SwiftUI
import VoltaserveCore

struct GroupEditName: View {
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        if let current = groupStore.current {
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
                            Text("Save Group Name")
                            if isSaving {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Change Group Name")
                        .font(.headline)
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

    private func performSave() {
        isSaving = true
        if let current = groupStore.current {
            VOErrorResponse.withErrorHandling {
                try await groupStore.patchName(current.id, options: .init(name: value))
            } success: {
                presentationMode.wrappedValue.dismiss()
                isSaving = false
            } failure: { message in
                isSaving = false
                errorTitle = "Error: Saving Group Name"
                errorMessage = message
                showError = true
            }
        }
    }
}
