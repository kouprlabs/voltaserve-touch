import PDFKit
import SwiftUI

class VPDFDocument: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    private var store: VPDFStore
    private var idRandomizer = IdRandomizer(Constants.fileIds)

    private var fileId: String {
        idRandomizer.value
    }

    init(config: Config, token: Token) {
        store = VPDFStore(config: config, token: token)
    }

    func loadPDF() {
        DispatchQueue.global().async {
            if let loadedDocument = PDFDocument(url: self.store.urlForFile(id: self.fileId)) {
                DispatchQueue.main.async {
                    self.pdfDocument = loadedDocument
                }
            }
        }
    }

    func shuffleFileId() {
        idRandomizer.shuffle()
    }

    private enum Constants {
        static let fileIds = [
            "eV0k2Deym6ekZ", // hdr2023-24reporten
            "XX7G1r3za358J", // human-freedom-index-2022
            "kd9EWp2pDxX0Y" // Choose-an-automation-tool-ebook-Red-Hat-Developer
        ]
    }
}
