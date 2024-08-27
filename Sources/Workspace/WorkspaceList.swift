import SwiftUI

struct WorkspaceList: View {
    @State var showingAccount = false
    @State var selection: String?
    var workspaces = [
        "Workspace Alpha",
        "Workspace Teta",
        "Workspace Omega"
    ]

    var body: some View {
        NavigationStack {
            List(workspaces, id: \.self) { workspace in
                NavigationLink {
                    FileList()
                        .navigationTitle(workspace)
                } label: {
                    WorkspaceRow(workspace)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                Button {
                    showingAccount.toggle()
                } label: {
                    Label("Account", systemImage: "person.crop.circle")
                }
            }
            .sheet(isPresented: $showingAccount) {
                Account()
            }
        }
    }
}

#Preview {
    WorkspaceList()
}
