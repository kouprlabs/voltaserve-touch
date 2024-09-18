import PDFKit
import SwiftUI
import VoltaserveCore

class PDFStore: ObservableObject {
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

    func url(_ id: String) -> URL? {
        fileClient?.urlForPreview(id, fileExtension: "pdf")
    }
}
