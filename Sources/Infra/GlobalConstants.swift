import Foundation
import Voltaserve

enum GlobalConstants {
    static let token = VOToken.Value(
        // swiftlint:disable:next line_length
        accessToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjM4NzM0ODYsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNjQ2NTQ4Nn0.8v4tVsqBOduAzVmpTlFut-VG7XsfksXWCee8jl3eTOQ",
        expiresIn: 1_726_465_486,
        tokenType: "Bearer",
        refreshToken: "f7599a593043424eb74e1a3c3614146e"
    )
    static let config = Config(
        apiURL: "http://192.168.100.24:8080/v2",
        idpURL: "http://192.168.100.24:8081/v2"
    )
}
