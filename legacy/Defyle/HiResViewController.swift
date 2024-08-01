import UIKit

class HiResViewController: UIViewController {
  fileprivate var documentView: HiResView!
  fileprivate var zoomViewController: ZoomViewController?
  fileprivate var zoomBarButton: UIBarButtonItem!
  fileprivate var closeBarButton: UIBarButtonItem!
  var apiUrl: String!
  var accessToken: String!
  var partitionId: String! = nil;
  var workspaceId: String! = nil;
  var node: [String: Any]!
  var zoomLevels: NSArray!

  override func viewDidLoad() {
    super.viewDidLoad()

    zoomBarButton = UIBarButtonItem(title: "Zoom", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HiResViewController.zoomButtonTapped(_:)))
    self.navigationItem.rightBarButtonItem = zoomBarButton
    self.navigationController?.navigationBar.isTranslucent = false

    closeBarButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HiResViewController.closeButtonTapped(_:)))
    self.navigationItem.leftBarButtonItem = closeBarButton
    self.navigationController?.navigationBar.isTranslucent = false

    self.documentView = self.view as? HiResView
    self.documentView.backgroundColor = UIColor.black
    self.documentView.node = self.node
    self.documentView.accessToken = self.accessToken
    self.documentView.apiUrl = self.apiUrl
    self.documentView.workspaceId = self.workspaceId
    self.documentView.partitionId = self.partitionId
    if let images = self.zoomLevels {
      if images.count > 0 {
        let initialImageIndex = images.count == 1 ? 0 : images.count - 1
        self.documentView.fillGridWithImage(images[initialImageIndex] as! [String: Any])
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.documentView.resetGrid()
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isTranslucent = false
  }

  @objc func zoomButtonTapped(_ sender: AnyObject) {
    zoomViewController = ZoomViewController()
    zoomViewController?.images = self.zoomLevels
    let documentView: HiResView = self.view as! HiResView
    zoomViewController?.documentView = documentView
    self.navigationController!.pushViewController(zoomViewController!, animated: true)
  }

  @objc func closeButtonTapped(_ sender: AnyObject) {
    self.navigationController!.dismiss(animated: true, completion: nil)
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      self.documentView.setNeedsDisplay()
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func loadView() {
    self.view = HiResView()
    self.view.frame = UIScreen.main.bounds
  }
}

