import UIKit

class ZoomViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
  var tableView: UITableView!
  var images: NSArray!
  var documentView: HiResView!

  override func viewDidLoad() {
    self.navigationItem.title = "Zoom"

    tableView = UITableView(frame: self.view.frame)
    tableView.dataSource = self
    tableView.delegate = self

    self.view.addSubview(tableView)
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isTranslucent = true
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      self.tableView.frame.size = size
    })
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "ZoomCell")
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ZoomCell")
    }
    let image = images[(indexPath as NSIndexPath).row] as! NSDictionary
    let scaleDownPercentage = image["scaleDownPercentage"] as! NSNumber
    cell?.textLabel?.text = "\(Int(round(scaleDownPercentage.floatValue)))%"
    return cell!
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return images.count;
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.navigationController!.popViewController(animated: true)

    let image = self.images[indexPath.row] as! [String: Any]
    self.documentView.fillGridWithImage(image)
  }
}
