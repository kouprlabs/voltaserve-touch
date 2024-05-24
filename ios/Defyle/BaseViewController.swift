import UIKit

class BaseViewController: UIViewController {
  lazy var activityIndicator: UIActivityIndicatorView = {
    var ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    ai.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3)
    ai.frame = self.view.frame
    return ai
  }()

  override func loadView() {
    self.view = UIView(frame: UIScreen.main.bounds)
    self.view.backgroundColor = UIColor.white
  }

  func startActivityIndicator() {
    self.view.isUserInteractionEnabled = false
    self.view.addSubview(self.activityIndicator)
    self.activityIndicator.startAnimating()
  }

  func stopActivityIndicator() {
    self.activityIndicator.stopAnimating()
    self.activityIndicator.removeFromSuperview()
    self.view.isUserInteractionEnabled = true
  }
}
