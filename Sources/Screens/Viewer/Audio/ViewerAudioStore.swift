import PDFKit
import SwiftUI
import VoltaserveCore

class ViewerAudioStore: ObservableObject {
    @Published var url: URL?

    var id: String? {
        didSet {
            url = buildURL(id: id, token: token, fileExtension: fileExtension)
        }
    }

    var fileExtension: String? {
        didSet {
            url = buildURL(id: id, token: token, fileExtension: fileExtension)
        }
    }

    var token: VOToken.Value? {
        didSet {
            if let token {
                url = buildURL(id: id, token: token, fileExtension: fileExtension)
            }
        }
    }

    private func buildURL(id: String?, token: VOToken.Value?, fileExtension: String?) -> URL? {
        guard let id, let fileExtension, let token else { return nil }
        return VOFile(
            baseURL: Config.production.apiURL,
            accessToken: token.accessToken
        ).urlForPreview(id, fileExtension: fileExtension)
    }
}
