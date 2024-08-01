import UIKit
import WebKit
import PDFKit
import Alamofire

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {
  var webView: WKWebView!
  var pdfView: PDFView!

  override func loadView() {
    let contentController = WKUserContentController();
    contentController.add(self, name: "hiResPreview")
    contentController.add(self, name: "pdfPreview")

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = contentController
    webView = WKWebView(frame: .zero, configuration: configuration)
    webView.uiDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.red;

    var config: NSDictionary?
    if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
      config = NSDictionary(contentsOfFile: path)
    }

    let url = config!["URL"] as! String
    let request = URLRequest(url: URL(string:url)!)
    webView.load(request)
  }

  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if (message.name == "hiResPreview") {
      let jsMessage = JSMessage(json: message.body as! String)

      DispatchQueue.main.async(execute: {
        let documentViewController = HiResViewController()
        documentViewController.accessToken = jsMessage.accessToken
        documentViewController.apiUrl = jsMessage.apiUrl
        documentViewController.workspaceId = jsMessage.workspaceId
        documentViewController.partitionId = jsMessage.partitionId
        documentViewController.node = jsMessage.inode
        documentViewController.zoomLevels = jsMessage.zoomLevels

        let navController = UINavigationController(rootViewController: documentViewController)
        self.present(navController, animated: true, completion: nil)
      })
    } else if (message.name == "pdfPreview") {
      let jsMessage = JSMessage(json: message.body as! String)

      let headers: [String: String] = [
        "Authorization": "Bearer " + jsMessage.accessToken!,
        "WorkspaceId": jsMessage.workspaceId!,
        "PartitionId": jsMessage.partitionId!
      ]

      let nodeId = jsMessage.inode["id"] as! String
      let url = "\(jsMessage.apiUrl!)/workspaces/\(jsMessage.workspaceId!)/inodes/\(nodeId)/downloadPreview"
      Alamofire.request(url, method: .get, headers: headers).responseData { response in
        if let data = response.data {
          DispatchQueue.main.async(execute: {
            let pdfViewController = PDFViewController()
            pdfViewController.data = data

            let navController = UINavigationController(rootViewController: pdfViewController)
            self.present(navController, animated: true, completion: nil)
          })
        }
      }
    }
  }
}
