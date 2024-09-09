import PDFKit
import SwiftUI
import VoltaserveCore

class ViewerImageStore: ObservableObject {
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

    func url(_ id: String, fileExtension: String) -> URL? {
        client?.urlForPreview(id, fileExtension: fileExtension)
    }
}
