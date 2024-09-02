import SwiftUI
import Voltaserve

struct GroupSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            if let group = groupStore.current {
                VStack {
                    VOAvatar(name: group.name, size: 100)
                    Form {
                        Section(header: VOSectionHeader("Basics")) {
                            NavigationLink(destination: Text("Change Name")) {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    Text(group.name)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: VOSectionHeader("Advanced")) {
                            Button("Delete Group", role: .destructive) {
                                showDelete = true
                            }
                        }
                    }
                }
                .alert("Delete Group", isPresented: $showDelete) {
                    Button("Delete Permanently", role: .destructive) {}
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
