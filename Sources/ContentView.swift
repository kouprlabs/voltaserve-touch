import Combine
import SwiftUI
import VoltaserveCore

struct ContentView: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var accountStore: AccountStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @EnvironmentObject private var groupStore: GroupStore
    @EnvironmentObject private var mosaicStore: MosaicStore
    @EnvironmentObject private var glbStore: GLBStore
    @EnvironmentObject private var pdfStore: PDFStore
    @EnvironmentObject private var imageStore: ImageStore
    @EnvironmentObject private var videoStore: VideoStore
    @State private var timer: Timer?
    @State private var showSignIn = false

    var body: some View {
        MainView()
            .onAppear {
                if let token = tokenStore.loadFromKeyChain() {
                    if token.isExpired {
                        tokenStore.token = nil
                        tokenStore.deleteFromKeychain()
                        showSignIn = true
                    } else {
                        tokenStore.token = token
                    }
                } else {
                    showSignIn = true
                }
                startTokenTimer()
            }
            .onDisappear { stopTokenTimer() }
            .fullScreenCover(isPresented: $showSignIn) {
                SignIn {
                    startTokenTimer()
                    showSignIn = false
                }
            }
            .onAppear {
                if let token = tokenStore.token {
                    assignTokenToStores(token)
                }
            }
            .onChange(of: tokenStore.token) { oldToken, newToken in
                if let newToken {
                    assignTokenToStores(newToken)
                }
                if oldToken != nil, newToken == nil {
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
        mosaicStore.token = token
        glbStore.token = token
        pdfStore.token = token
        imageStore.token = token
        videoStore.token = token
    }

    func startTokenTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard tokenStore.token != nil else { return }
            if let token = tokenStore.token, token.isExpired {
                Task {
                    if let newToken = try await tokenStore.refreshTokenIfNecessary() {
                        Task { @MainActor in
                            tokenStore.token = newToken
                            tokenStore.saveInKeychain(newToken)
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
