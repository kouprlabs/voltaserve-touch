import GLTFKit2
import SwiftUI
import VoltaserveCore

class GLBStore: ObservableObject {
    private var client: VOFile?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    func loadAsset(_ id: String, completion: @escaping (GLTFAsset?, Error?) -> Void) {
        let url = client?.urlForPreview(id, fileExtension: "glb")
        if let url {
            GLTFAsset.load(
                with: url,
                options: [:]
            ) { _, status, maybeAsset, maybeError, _ in
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    if status == .complete {
                        completion(maybeAsset, nil)
                    } else if let error = maybeError {
                        completion(nil, error)
                    }
                }
            }
        }
    }
}
