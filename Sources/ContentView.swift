import Combine
import SwiftUI
import Voltaserve

struct ContentView: View {
    @State private var timerSubscription: Cancellable?
    @State private var showSignIn = true

    var body: some View {
        MainView()
            .onAppear {
                startBackgroundTask(interval: 3) {
                    print("Task executed")
                }
            }
            .onDisappear {
                timerSubscription?.cancel()
            }
            .fullScreenCover(isPresented: $showSignIn) {
                SignIn {
                    showSignIn = false
                }
            }
    }

    func startBackgroundTask(interval: TimeInterval, task: @escaping () -> Void) {
        timerSubscription = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                task()
            }
    }
}

#Preview {
    ContentView()
}
