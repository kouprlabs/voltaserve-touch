import SwiftUI

struct WorkspaceList: View {
    @State var showingAccount = false
    @State var selection: String?
    var workspaces: [String] = []

    init(showingAccount: Bool = false, selection: String? = nil, workspaces _: [String] = []) {
        self.showingAccount = showingAccount
        self.selection = selection
        for index in 1 ..< 50 {
            workspaces.append("Workspace \(index)")
        }
    }

    var body: some View {
        NavigationStack {
            List(workspaces, id: \.self) { workspace in
                NavigationLink {
                    FileList()
                        .navigationTitle(workspace)
                } label: {
                    Text(workspace)
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
