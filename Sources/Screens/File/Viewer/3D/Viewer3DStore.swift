import GLTFKit2
import SwiftUI
import VoltaserveCore

class Viewer3DStore: ObservableObject {
    @Published var url: URL?

    var id: String? {
        didSet {
            url = buildURL(id: id, token: token)
        }
    }

    var token: VOToken.Value? {
        didSet {
            url = buildURL(id: id, token: token)
        }
    }

    private func buildURL(id: String?, token: VOToken.Value?) -> URL? {
        guard let id, let token else { return nil }
        return VOFile(
            baseURL: Config.production.apiURL,
            accessToken: token.accessToken
        ).urlForPreview(id, fileExtension: "glb")
    }
}
