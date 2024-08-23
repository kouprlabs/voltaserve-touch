import PDFKit
import SwiftUI
import Voltaserve

class ViewerPDFBasicStore: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var loadedThumbnails: [Int: UIImage] = [:]
    @Published var isLoading = false

    private var data: VOFile
    private var randomizer = Randomizer(Constants.fileIds)

    private var fileId: String {
        randomizer.value
    }

    init(config: Config, token: VOToken.Value) {
        data = VOFile(baseURL: config.apiURL, accessToken: token.accessToken)
    }

    func loadPDF() {
        // Clear existing thumbnails
        DispatchQueue.main.async {
            self.loadedThumbnails = [:]
            self.isLoading = true
        }

        DispatchQueue.global().async {
            if let loadedDocument = PDFDocument(url: self.data.urlForPreview(self.fileId, fileExtension: "pdf")) {
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
        randomizer.shuffle()
        loadPDF()
    }

    private enum Constants {
        static let fileIds = [
            "2WNJM7poqKLjP" // hdr2023-24reporten
        ]
    }
}
