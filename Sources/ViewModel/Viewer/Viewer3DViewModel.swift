import GLTFKit2
import SwiftUI

class Viewer3DViewModel: ObservableObject {
    private var store: FileModel
    private var idRandomizer = IDRandomizer(Constants.fileIds)

    private var fileId: String {
        idRandomizer.value
    }

    init(config: Config, token: Token) {
        store = FileModel(config: config, token: token)
    }

    func loadAsset(completion: @escaping (GLTFAsset?, Error?) -> Void) {
        GLTFAsset.load(with: store.url(id: fileId), options: [:]) { _, status, maybeAsset, maybeError, _ in
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
            "7DjrG5Vy3pqRX"  // sofa
        ]
    }
}
