// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import SwiftData
import SwiftUI

public struct Voltaserve: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.modelContext) private var context
    @Query private var servers: [Server]
    @State private var timer: Timer?
    @State private var signInIsPresented = false
    @State private var selection: TabType?
    private var extensions = Extensions()

    public enum TabType: Hashable {
        case workspaces
        case groups
        case organizations
        case custom(String)
    }

    public struct TabItem {
        public let title: String
        public let systemImageName: String
        public let tabType: TabType
        public let view: AnyView

        public init(title: String, systemImageName: String, tabType: TabType, view: AnyView) {
            self.title = title
            self.systemImageName = systemImageName
            self.tabType = tabType
            self.view = view
        }
    }

    public class Extensions: ObservableObject {
        @Published public var tabs = Tabs()

        public struct Tabs {
            public let selection: TabType?
            public let items: [TabItem]?

            public init(selection: TabType? = nil, items: [TabItem]? = nil) {
                self.selection = selection
                self.items = items
            }
        }

        public init(tabs: Tabs? = nil) {
            if let tabs = tabs {
                self.tabs = tabs
            }
        }
    }

    public init(_ extensions: Extensions? = nil) {
        if let extensions = extensions {
            self.extensions = extensions
        }
    }

    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            TabView(selection: $selection) {
                if let tabs = self.extensions.tabs.items {
                    ForEach(tabs, id: \.tabType) { tab in
                        Tab(tab.title, systemImage: tab.systemImageName, value: tab.tabType) {
                            tab.view
                        }
                    }
                }
                Tab("Workspaces", systemImage: "internaldrive", value: TabType.workspaces) {
                    WorkspaceList()
                }
                Tab("Groups", systemImage: "person.2.fill", value: TabType.groups) {
                    GroupList()
                }
                Tab("Organizations", systemImage: "flag", value: TabType.organizations) {
                    OrganizationList()
                }
            }
            .onAppear {
                if let token = tokenStore.loadFromKeyChain() {
                    if token.isExpired {
                        tokenStore.token = nil
                        tokenStore.deleteFromKeychain()
                        signInIsPresented = true
                    } else {
                        tokenStore.token = token
                    }
                } else {
                    signInIsPresented = true
                }

                startTokenTimer()

                if !servers.contains(where: \.isCloud) {
                    context.insert(Server.cloud)
                }
                if UserDefaults.standard.server == nil {
                    UserDefaults.standard.server = Server.cloud
                }
            }
            .onDisappear { stopTokenTimer() }
            .onChange(of: tokenStore.token) { oldToken, newToken in
                if oldToken != nil, newToken == nil {
                    stopTokenTimer()
                    // This is hack to mitigate a SwiftUI bug that causes `fullScreenCover` to dismiss
                    // itself unexpectedly without user interaction or a direct code-triggered dismissal.
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        DispatchQueue.main.async {
                            signInIsPresented = true
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $signInIsPresented) {
                SignIn {
                    startTokenTimer()
                    signInIsPresented = false
                }
            }
            .font(.custom(VOMetrics.bodyFontFamily, size: VOMetrics.bodyFontSize))
            .environmentObject(extensions)
            .modelContainer(for: Server.self)
        }
    }

    private func startTokenTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard tokenStore.token != nil else { return }
            if let token = tokenStore.token, token.isExpired {
                Task {
                    if let newToken = try await tokenStore.refreshTokenIfNecessary() {
                        DispatchQueue.main.async {
                            tokenStore.token = newToken
                            tokenStore.saveInKeychain(newToken)
                        }
                    }
                }
            }
        }
    }

    private func stopTokenTimer() {
        timer?.invalidate()
        timer = nil
    }
}
