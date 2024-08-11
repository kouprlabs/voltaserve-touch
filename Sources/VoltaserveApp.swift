import SwiftUI

@main
struct VoltaserveApp: App {
    // swiftlint:disable:next line_length
    var token = TokenData.Value(accessToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y")
    var config = Config(apiUrl: "http://localhost:8080")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Viewer3DViewModel(config: config, token: token))
                .environmentObject(ViewerPDFViewModel(config: config, token: token))
                .environmentObject(ViewerPDFBasicViewModel(config: config, token: token))
                .environmentObject(ViewerMosaicViewModel(config: config, token: token))
        }
    }
}
