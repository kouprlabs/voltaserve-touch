import UIKit
import Alamofire

class HiResView: UIView {
  fileprivate var grid: [[UIImage?]] = []
  fileprivate var concurrencyAllocations: [[Bool]] = []
  fileprivate var imageSize: CGSize = CGSize(width: 0, height: 0)
  fileprivate var documentLocation: CGPoint = CGPoint(x: 0, y: 0)
  fileprivate var touchLocation: CGPoint = CGPoint(x: 0, y: 0)
  fileprivate var delta: CGPoint = CGPoint(x: 0, y: 0)
  fileprivate var rowCount: Int?
  fileprivate var colCount: Int?
  fileprivate var gridLoaded: Bool = false
  fileprivate var touchDown: Bool = false
  fileprivate var index: Int = 0
  fileprivate var divWidth: Int!
  fileprivate var divHeight: Int!
  fileprivate var numberOfBackgroundThreads: Int = 0
  var apiUrl: String!
  var accessToken: String!
  var partitionId: String! = nil;
  var workspaceId: String! = nil;
  var node: [String: Any]?
  var image: [String: Any]?

  func resetGrid() {
    self.gridLoaded = false
    self.grid = []
    self.concurrencyAllocations = []
    self.documentLocation = CGPoint(x: 0, y: 0)
    self.delta = CGPoint(x: 0, y: 0)
    self.rowCount = 0
    self.colCount = 0
  }

  func fillGridWithImage(_ image: [String: Any]) {
    resetGrid()

    self.image = image

    self.index = image["index"] as! Int
    self.imageSize.width = image["width"] as! CGFloat
    self.imageSize.height = image["height"] as! CGFloat
    self.rowCount = image["rows"] as? Int
    self.colCount = image["cols"] as? Int

    let tile = image["tile"] as? NSDictionary

    self.divWidth = tile!["width"] as? Int
    self.divHeight = tile!["height"] as? Int

    for _ in 0...(self.rowCount! - 1) {
      var rowArray = Array<UIImage?>()
      for _ in 0...(self.colCount! - 1) {
        rowArray.append(nil)
      }
      self.grid.append(rowArray)
    }

    for _ in 0...(self.rowCount! - 1) {
      var rowArray = Array<Bool>()
      for _ in 0...(self.colCount! - 1) {
        rowArray.append(false)
      }
      self.concurrencyAllocations.append(rowArray)
    }

    gridLoaded = true
    setNeedsDisplay()
  }

  override func draw(_ rect: CGRect) {
    if gridLoaded {
      let screenRect = UIScreen.main.bounds
      for row in 0...(self.rowCount! - 1) {
        for col in 0...(self.colCount! - 1) {
          var x: CGFloat = CGFloat(col * self.divWidth)
          var y: CGFloat = CGFloat(row * self.divHeight)
          if self.imageSize.width > 0 && self.imageSize.height > 0 && touchDown {
            self.documentLocation.x = CGFloat(self.touchLocation.x - self.delta.x)
            self.documentLocation.y = CGFloat(self.touchLocation.y - self.delta.y)
          }
          x += documentLocation.x
          y += documentLocation.y

          if screenRect.intersects(CGRect(x: x, y: y, width: CGFloat(self.divWidth), height: CGFloat(self.divHeight))) {
            if self.grid[row][col] == nil {
              UIColor.black.setFill()
              UIGraphicsGetCurrentContext()?.fill(CGRect(x: x, y: y, width: CGFloat(self.divWidth), height: CGFloat(self.divHeight)))

              if self.numberOfBackgroundThreads < 3 {
                DispatchQueue.global().async { [row, col] in
                  self.numberOfBackgroundThreads += 1;
                  let headers = [
                    "Authorization": "Bearer " + self.accessToken!,
                    "WorkspaceId": self.workspaceId!,
                    "PartitionId": self.partitionId!
                  ]
                  let nodeId = self.node!["id"] as! String
                  if self.concurrencyAllocations[row][col] == false {
                    self.concurrencyAllocations[row][col] = true
                    let url = self.apiUrl! + "/workspaces/\(self.workspaceId!)/inodes/\(nodeId)/tileMaps/tiles/\(self.index)/\(row)/\(col)"
                    Alamofire.request(url, method: .get, headers: headers).responseData { response in
                      if let data = response.data {
                        if let image = UIImage(data: data) {
                          self.grid[row][col] = image
                          DispatchQueue.main.async {
                            self.numberOfBackgroundThreads -= 1
                            if self.numberOfBackgroundThreads < 0 {
                              self.numberOfBackgroundThreads = 0
                            }
                            self.setNeedsDisplay()
                          }
                        }
                      }
                    }
                  }
                }
              }
            } else {
              self.grid[row][col]?.draw(at: CGPoint(x: x, y: y))
            }
          }
        }
      }
    } else {
      UIColor.gray.setFill()
      UIRectFill(rect);
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.touchLocation = CGPoint(x: 0, y: 0)
    touchDown = false
    setNeedsDisplay()
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first! as UITouch

    let point = touch.location(in: self)

    if (point.x >= self.documentLocation.x &&
        point.y >= self.documentLocation.y &&
        point.x <= self.documentLocation.x + imageSize.width &&
        point.y <= self.documentLocation.y + imageSize.height) {
      self.touchLocation = point

      setNeedsDisplay()
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first! as UITouch

    let point = touch.location(in: self)

    if (point.x >= self.documentLocation.x &&
        point.y >= self.documentLocation.y &&
        point.x <= self.documentLocation.x + imageSize.width &&
        point.y <= self.documentLocation.y + imageSize.height) {
      self.touchLocation = point
      self.delta.x = self.touchLocation.x - self.documentLocation.x
      self.delta.y = self.touchLocation.y - self.documentLocation.y

      setNeedsDisplay()

      touchDown = true
    }
  }

}




