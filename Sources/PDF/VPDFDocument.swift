import Foundation
import PDFKit

class VPDFDocument: ObservableObject {
    private var apiUrl: String = "http://localhost:8080"
    // swiftlint:disable:next line_length
    private var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    private var fileId: String = "eV0k2Deym6ekZ"

    @Published var pdfDocument: PDFDocument?

    var url: URL {
        URL(string: "\(apiUrl)/v2/files/\(fileId)/preview.pdf?access_token=\(accessToken)")!
    }

    func loadPDF() {
        DispatchQueue.global().async {
            if let loadedDocument = PDFDocument(url: self.url) {
                DispatchQueue.main.async {
                    self.pdfDocument = loadedDocument
                }
            } else {
                print("Failed to load PDF document")
            }
        }
    }
}
