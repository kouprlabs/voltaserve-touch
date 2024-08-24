import SwiftUI
import Voltaserve

struct ContentView: View {
    @State var selection: Tab = .workspaces

    enum Tab {
        case workspaces
        case groups
        case organizations
    }

    var body: some View {
        TabView(selection: $selection) {
            WorkspaceList()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.workspaces)

            GroupList()
                .tabItem {
                    Label("Groups", systemImage: "person.2.fill")
                }
                .tag(Tab.groups)

            OrganizationList()
                .tabItem {
                    Label("Organizations", systemImage: "flag")
                }
                .tag(Tab.organizations)
        }
    }
}

#Preview {
    ContentView()
}
