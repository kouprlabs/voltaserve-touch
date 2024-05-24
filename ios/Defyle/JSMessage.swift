import Foundation

class JSMessage {
  var accessToken: String!
  var apiUrl: String!
  var workspaceId: String!
  var partitionId: String!
  var inode: [String: AnyObject]!
  var zoomLevels: NSArray!

  init(json: String) {
    do {
      let jsonData = json.data(using: String.Encoding.utf8)
      let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
      let credentials = jsonDictionary["credentials"] as! [String: AnyObject]

      accessToken = credentials["access_token"] as? String
      apiUrl = jsonDictionary["apiUrl"] as? String
      workspaceId = jsonDictionary["workspaceId"] as? String
      partitionId = jsonDictionary["partitionId"] as? String
      inode = jsonDictionary["inode"] as? [String: AnyObject]
      zoomLevels = jsonDictionary["zoomLevels"] as? NSArray
    } catch _ {
    }
  }
}
