import PDFKit
import SwiftUI

class VPDFDocument: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var loadedThumbnails: [Int: UIImage] = [:]
    @Published var isLoading: Bool = false
    private var store: VPDFStore
    private var idRandomizer = IdRandomizer(Constants.fileIds)

    private var fileId: String {
        idRandomizer.value
    }

    init(config: Config, token: Token) {
        store = VPDFStore(config: config, token: token)
    }

    func loadPDF() {
        // Clear existing thumbnails
        DispatchQueue.main.async {
            self.loadedThumbnails = [:]
            self.isLoading = true
        }

        DispatchQueue.global().async {
            if let loadedDocument = PDFDocument(url: self.store.urlForPreview(id: self.fileId)) {
                DispatchQueue.main.async {
                    self.pdfDocument = loadedDocument
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    func loadThumbnails(for indices: [Int]) {
        guard let document = pdfDocument else { return }

        let newThumbnails = indices.compactMap { index -> (Int, UIImage)? in
            guard document.pageCount > index, let page = document.page(at: index) else { return nil }
            let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 150), for: .mediaBox)
            return (index, thumbnail)
        }
        DispatchQueue.main.async {
            for (index, thumbnail) in newThumbnails {
                self.loadedThumbnails[index] = thumbnail
            }
        }
    }

    func shuffleFileId() {
        pdfDocument = nil
        idRandomizer.shuffle()
        loadPDF()
    }

    private enum Constants {
        static let fileIds = [
            "YoXAmbYzmrZ9l" // human-freedom-index-2022
        ]
    }
}
