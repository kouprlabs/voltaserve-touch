import SwiftUI
import Voltaserve

struct WorkspaceSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            if let workspace = workspaceStore.current {
                VStack {
                    Form {
                        Section(header: Text("Storage")) {
                            VStack(alignment: .leading) {
                                Text("3.43 GB of 4 GB used")
                                ProgressView(value: 0.5)
                            }
                            NavigationLink(destination: Text("Change Storage Capacity")) {
                                HStack {
                                    Text("Capacity")
                                    Spacer()
                                    Text("4 GB")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: Text("Basics")) {
                            NavigationLink(destination: Text("Change Name")) {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    Text(workspace.name)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: Text("Advanced")) {
                            Button("Delete Workspace", role: .destructive) {
                                showDeleteAlert = true
                            }
                        }
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
                .alert("Delete Workspace", isPresented: $showDeleteAlert) {
                    Button("Delete Permanently", role: .destructive) {}
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you would like to delete this workspace?")
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

#Preview {
    WorkspaceSettings()
        .environmentObject(AuthStore())
        .environmentObject(WorkspaceStore())
}
