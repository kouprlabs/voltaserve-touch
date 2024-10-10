import PDFKit
import SwiftUI
import VoltaserveCore

class ViewerVideoStore: ObservableObject {
    @Published var url: URL?

    var id: String? {
        didSet {
            url = buildURL(id: id, fileExtension: fileExtension, token: token)
        }
    }

    var fileExtension: String? {
        didSet {
            url = buildURL(id: id, fileExtension: fileExtension, token: token)
        }
    }

    var token: VOToken.Value? {
        didSet {
            url = buildURL(id: id, fileExtension: fileExtension, token: token)
        }
    }

    private func buildURL(id: String?, fileExtension: String?, token: VOToken.Value?) -> URL? {
        guard let id, let fileExtension, let token else { return nil }
        return VOFile(
            baseURL: Config.production.apiURL,
            accessToken: token.accessToken
        ).urlForPreview(id, fileExtension: fileExtension)
    }
}
