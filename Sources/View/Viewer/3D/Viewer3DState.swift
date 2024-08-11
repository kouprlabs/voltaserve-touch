import GLTFKit2
import SwiftUI

class Viewer3DState: ObservableObject {
    private var data: File
    private var idRandomizer = Randomizer(Constants.fileIds)

    private var fileId: String {
        idRandomizer.value
    }

    init(config: Config, token: Token.Value) {
        data = File(config: config, token: token)
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
            "X5B4GmoRWNO4W", // girl
            "mqMeKPo7zza5p", // armstrong
            "ApNxljyZG3AYd", // car
            "nDBzl4JE3M4vN", // mixer
            "Q9BEQVo3x4dqn", // vase
            "7DjrG5Vy3pqRX" // sofa
        ]
    }
}
