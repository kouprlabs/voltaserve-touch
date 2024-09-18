import PDFKit
import SwiftUI
import VoltaserveCore

class ImageStore: ObservableObject {
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

    func url(_ id: String, fileExtension: String) -> URL? {
        fileClient?.urlForPreview(id, fileExtension: fileExtension)
    }
}
