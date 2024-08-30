import PDFKit
import SwiftUI
import Voltaserve

class ViewerPDFStore: ObservableObject {
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

    func url(_ id: String) -> URL? {
        client?.urlForPreview(id, fileExtension: "pdf")
    }
}
