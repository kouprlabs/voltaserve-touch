import GLTFKit2
import SwiftUI

class V3DDocument: ObservableObject {
    private var apiUrl: String = "http://localhost:8080"
    // swiftlint:disable:next line_length
    private var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    private var fileId: String = "X5B4GmoRWNO4W"

    func loadAsset(completion: @escaping (GLTFAsset?) -> Void) {
        // swiftlint:disable:next line_length
        GLTFAsset.load(with: URL(string: "\(apiUrl)/v2/files/\(fileId)/preview.glb?access_token=\(accessToken)")!, options: [:]) { _, status, maybeAsset, maybeError, _ in
            if status == .complete {
                completion(maybeAsset)
            } else if let error = maybeError {
                print("Failed to load glTF asset: \(error)")
            }
        }
    }
}
