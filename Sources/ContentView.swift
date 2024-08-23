import SwiftUI
import Voltaserve

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Workspaces", systemImage: "externaldrive") {
                WorkspaceList()
            }
            Tab("Groups", systemImage: "person.2.fill") {
                GroupList()
            }
            Tab("Organizations", systemImage: "flag") {
                OrganizationList()
            }
            Tab("Account", systemImage: "person.crop.circle") {
                Account()
            }
        }
    }
}

#Preview {
    ContentView()
}
