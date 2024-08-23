import SwiftUI
import Voltaserve

@main
struct VoltaserveApp: App {
    var token = VOToken.Value(
        // swiftlint:disable:next line_length
        accessToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjM4NzM0ODYsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNjQ2NTQ4Nn0.8v4tVsqBOduAzVmpTlFut-VG7XsfksXWCee8jl3eTOQ",
        expiresIn: 1_726_465_486,
        tokenType: "Bearer",
        refreshToken: "f7599a593043424eb74e1a3c3614146e"
    )
    var config = Config(
        apiURL: "http://localhost:8080/v2",
        idpURL: "http://localhost:8081/v2"
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Viewer3DStore(config: config, token: token))
                .environmentObject(ViewerPDFStore(config: config, token: token))
                .environmentObject(ViewerPDFBasicStore(config: config, token: token))
                .environmentObject(ViewerMosaicStore(config: config, token: token))
        }
    }
}
