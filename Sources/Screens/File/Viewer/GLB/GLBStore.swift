import GLTFKit2
import SwiftUI
import VoltaserveCore

class GLBStore: ObservableObject {
    private var fileClient: VOFile?

    var token: VOToken.Value? {
        didSet {
            if let token {
                fileClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    func loadAsset(_ id: String, completion: @escaping (GLTFAsset?, Error?) -> Void) {
        let url = fileClient?.urlForPreview(id, fileExtension: "glb")
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
