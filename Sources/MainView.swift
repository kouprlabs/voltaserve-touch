import SwiftUI
import VoltaserveCore

struct MainView: View {
    @State private var selection: TabType = .workspaces

    enum TabType {
        case workspaces
        case groups
        case organizations
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: TabType.workspaces) {
                WorkspaceList()
            }
            Tab("Groups", systemImage: "person.2.fill", value: TabType.groups) {
                GroupList()
            }
            Tab("Organizations", systemImage: "flag", value: TabType.organizations) {
                OrganizationList()
            }
        }
    }
}
