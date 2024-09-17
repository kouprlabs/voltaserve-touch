import Combine
import SwiftUI
import VoltaserveCore

struct ContentView: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var accountStore: AccountStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @EnvironmentObject private var groupStore: GroupStore
    @EnvironmentObject private var organizationMembersStore: OrganizationMembersStore
    @EnvironmentObject private var groupMembersStore: GroupMembersStore
    @EnvironmentObject private var mosaicStore: MosaicStore
    @EnvironmentObject private var glbStore: GLBStore
    @EnvironmentObject private var pdfStore: PDFStore
    @EnvironmentObject private var imageStore: ImageStore
    @EnvironmentObject private var videoStore: VideoStore
    @EnvironmentObject private var browserStore: BrowserStore
    @State private var timer: Timer?
    @State private var showSignIn = false

    var body: some View {
        MainView()
            .onAppear {
                if let token = KeychainManager.standard.getToken(KeychainManager.Constants.tokenKey) {
                    if token.isExpired {
                        authStore.token = nil
                        KeychainManager.standard.delete(KeychainManager.Constants.tokenKey)
                        showSignIn = true
                    } else {
                        authStore.token = token
                    }
                } else {
                    showSignIn = true
                }
                startTokenTimer()
            }
            .onDisappear { stopTokenTimer() }
            .fullScreenCover(isPresented: $showSignIn) {
                SignIn {
                    startStoreTimers()
                    startTokenTimer()
                    showSignIn = false
                }
            }
            .onAppear {
                if let token = authStore.token {
                    assignTokenToStores(token)
                }
            }
            .onChange(of: authStore.token) { oldToken, newToken in
                if let newToken {
                    assignTokenToStores(newToken)
                }
                if oldToken != nil, newToken == nil {
                    stopStoreTimers()
                    stopTokenTimer()
                    showSignIn = true
                }
            }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        accountStore.token = token
        workspaceStore.token = token
        organizationStore.token = token
        groupStore.token = token
        organizationMembersStore.token = token
        groupMembersStore.token = token
        mosaicStore.token = token
        glbStore.token = token
        pdfStore.token = token
        imageStore.token = token
        videoStore.token = token
        browserStore.token = token
    }

    func startStoreTimers() {
        accountStore.startTimer()
        workspaceStore.startTimer()
        organizationStore.startTimer()
        groupStore.startTimer()
        if let current = organizationStore.current {
            organizationMembersStore.startTimer(current.id)
        }
        if let current = groupStore.current {
            groupMembersStore.startTimer(current.id)
        }
    }

    func stopStoreTimers() {
        accountStore.stopTimer()
        workspaceStore.stopTimer()
        organizationStore.stopTimer()
        groupStore.stopTimer()
        organizationMembersStore.stopTimer()
        groupMembersStore.stopTimer()
    }

    func startTokenTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard authStore.token != nil else { return }
            if let token = authStore.token, token.isExpired {
                Task {
                    if let newToken = try await authStore.refreshTokenIfNecessary() {
                        Task { @MainActor in
                            authStore.token = newToken
                            KeychainManager.standard.saveToken(newToken, forKey: KeychainManager.Constants.tokenKey)
                        }
                    }
                }
            }
        }
    }

    func stopTokenTimer() {
        timer?.invalidate()
        timer = nil
    }
}
