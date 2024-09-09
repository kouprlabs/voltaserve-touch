import SwiftUI
import Voltaserve

struct GroupSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var shouldDismiss: (() -> Void)?

    init(_ shouldDismiss: (() -> Void)? = nil) {
        self.shouldDismiss = shouldDismiss
    }

    var body: some View {
        NavigationView {
            if let group = groupStore.current {
                VStack {
                    VOAvatar(name: group.name, size: 100)
                        .padding()
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
                }
                .alert("Delete Group", isPresented: $showDelete) {
                    Button("Delete Permanently", role: .destructive) {
                        isDeleting = true
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                            Task { @MainActor in
                                isDeleting = false
                                shouldDismiss?()
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you would like to delete this group?")
                }
                .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                    Button(VOTextConstants.errorAlertButtonLabel) {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Settings")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    GroupSettings()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(GroupStore(VOGroup.Entity.devInstance))
}
