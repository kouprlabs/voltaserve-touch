import Combine
import SwiftUI
import Voltaserve

struct ContentView: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var accountStore: AccountStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @EnvironmentObject private var groupStore: GroupStore
    @EnvironmentObject private var organizationMembersStore: OrganizationMembersStore
    @EnvironmentObject private var groupMembersStore: GroupMembersStore
    @State private var timerSubscription: Cancellable?
    @State private var showSignIn = false

    var body: some View {
        MainView()
            .onAppear {
                if let token = KeychainManager.standard.getToken(KeychainManager.Constants.tokenKey) {
                    if token.isExpired {
                        authStore.token = nil
                        showSignIn = true
                    } else {
                        authStore.token = token
                    }
                } else {
                    showSignIn = true
                }
                startBackgroundTask(interval: Constants.backgroundTaskInterval) {
                    performBackgroundTask()
                }
            }
            .onDisappear { stopBackgroundTask() }
            .fullScreenCover(isPresented: $showSignIn) {
                SignIn {
                    startStoreTimers()
                    startBackgroundTask(interval: Constants.backgroundTaskInterval) {
                        performBackgroundTask()
                    }
                    showSignIn = false
                }
            }
            .onChange(of: authStore.token) { oldToken, newToken in
                if oldToken != nil, newToken == nil {
                    stopStoreTimers()
                    stopBackgroundTask()
                    showSignIn = true
                }
            }
    }

    func startStoreTimers() {
        accountStore.startTimer()
        workspaceStore.startTimer()
        fileStore.startTimer()
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
        fileStore.stopTimer()
        organizationStore.stopTimer()
        groupStore.stopTimer()
        organizationMembersStore.stopTimer()
        groupMembersStore.stopTimer()
    }

    func performBackgroundTask() {
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

    func startBackgroundTask(interval: TimeInterval, task: @escaping () -> Void) {
        guard timerSubscription == nil else { return }
        timerSubscription = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                task()
            }
    }

    func stopBackgroundTask() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    enum Constants {
        static let backgroundTaskInterval: TimeInterval = 5
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthStore())
}
