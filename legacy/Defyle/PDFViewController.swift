import UIKit
import PDFKit

class PDFViewController: UIViewController {
  fileprivate var closeBarButton: UIBarButtonItem!
  var data: Data!
  var pdfView: PDFView!

  override func viewDidLoad() {
    super.viewDidLoad()

    closeBarButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PDFViewController.closeButtonTapped(_:)))
    self.navigationItem.leftBarButtonItem = closeBarButton
    self.navigationController?.navigationBar.isTranslucent = false
  }

  @objc func closeButtonTapped(_ sender: AnyObject) {
    self.navigationController!.dismiss(animated: true, completion: nil)
  }

  override func loadView() {
    if let pdfDocument = PDFDocument(data: self.data) {
      pdfView = PDFView(frame: UIScreen.main.bounds)
      pdfView.displayMode = .singlePageContinuous
      pdfView.autoScales = true
      pdfView.document = pdfDocument

      self.view = pdfView
    }
  }
}
