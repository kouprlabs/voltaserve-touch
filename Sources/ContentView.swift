import Combine
import SwiftData
import SwiftUI
import VoltaserveCore

struct ContentView: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var accountStore: AccountStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @EnvironmentObject private var invitationStore: InvitationStore
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var groupStore: GroupStore
    @EnvironmentObject private var mosaicStore: MosaicStore
    @EnvironmentObject private var glbStore: GLBStore
    @EnvironmentObject private var pdfStore: PDFStore
    @EnvironmentObject private var imageStore: ImageStore
    @EnvironmentObject private var videoStore: VideoStore
    @Environment(\.modelContext) private var context
    @Query private var servers: [Server]
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

                if let token = tokenStore.token {
                    assignTokenToStores(token)
                }

                startTokenTimer()

                if !servers.contains(where: \.isCloud) {
                    context.insert(Server.cloud)
                }
            }
            .onDisappear { stopTokenTimer() }
            .onChange(of: tokenStore.token) { oldToken, newToken in
                if let newToken {
                    assignTokenToStores(newToken)
                }
                if oldToken != nil, newToken == nil {
                    stopTokenTimer()
                    // This is hack to mitigate a SwiftUI bug that causes `fullScreenCover` to dismiss
                    // itself unexpectedly without user interaction or a direct code-triggered dismissal.
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        DispatchQueue.main.async {
                            showSignIn = true
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showSignIn) {
                SignIn {
                    startTokenTimer()
                    showSignIn = false
                }
            }
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        accountStore.token = token
        workspaceStore.token = token
        organizationStore.token = token
        groupStore.token = token
        invitationStore.token = token
        taskStore.token = token
        mosaicStore.token = token
        glbStore.token = token
        pdfStore.token = token
        imageStore.token = token
        videoStore.token = token
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
