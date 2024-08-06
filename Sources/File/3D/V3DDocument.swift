import GLTFKit2
import SwiftUI

class V3DDocument: ObservableObject {
    private var store: V3DStore
    private var fileId: String {
        Constants.fileIds.randomElement()!
    }

    init(config: Config, token: Token) {
        store = V3DStore(config: config, token: token)
    }

    func loadAsset(completion: @escaping (GLTFAsset?) -> Void) {
        GLTFAsset.load(with: store.urlForFile(id: fileId), options: [:]) { _, status, maybeAsset, maybeError, _ in
            if status == .complete {
                completion(maybeAsset)
            } else if let error = maybeError {
                print("Failed to load glTF asset: \(error.localizedDescription)")
            }
        }
    }

    private enum Constants {
        static let fileIds: [String] = [
            "Q9BEQVo3x4dqn", // girl
            "mqMeKPo7zza5p", // armstrong
            "ApNxljyZG3AYd", // car
            "nDBzl4JE3M4vN", // mixer
            "Q9BEQVo3x4dqn", // vase
            "7DjrG5Vy3pqRX" // sofa
        ]
    }
}
