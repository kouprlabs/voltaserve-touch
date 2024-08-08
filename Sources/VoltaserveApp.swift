import SwiftUI

@main
struct VoltaserveApp: App {
    // swiftlint:disable:next line_length
    var token = Token(accessToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y")
    var config = Config(apiUrl: "http://localhost:8080")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(V3DDocument(config: config, token: token))
                .environmentObject(VSegmentedPDFDocument(config: config, token: token))
                .environmentObject(VPDFDocument(config: config, token: token))
                .environmentObject(MosaicDocument(config: config, token: token))
        }
    }
}
