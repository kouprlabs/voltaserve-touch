import GLTFKit2
import SwiftUI
import Voltaserve

class Viewer3DState: ObservableObject {
    private var data: VOFile
    private var idRandomizer = Randomizer(Constants.fileIds)

    private var fileId: String {
        idRandomizer.value
    }

    init(config: Config, token: VOToken.Value) {
        data = VOFile(baseURL: config.apiURL, accessToken: token.accessToken)
    }

    func loadAsset(completion: @escaping (GLTFAsset?, Error?) -> Void) {
        GLTFAsset.load(
            with: data.urlForPreview(
                id: fileId,
                fileExtension: "glb"
            ),
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

    func shuffleFileId() {
        idRandomizer.shuffle()
    }

    private enum Constants {
        static let fileIds: [String] = [
            "Zae0LX1ZPEP3b", // Girl
            "dNj541y607koV", // Armstrong
            "2BAexoMypBzre", // Car
            "6VrYB5PK0rWVn", // Mixer
            "ZaELK7w1V0aLP", // Vase
            "D51zAXO1P5Yen" // Chair
        ]
    }
}
