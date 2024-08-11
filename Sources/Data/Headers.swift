import Alamofire
import Foundation

func headersWithAuthorization(_ accessToken: String) -> HTTPHeaders {
    ["Authorization": "Bearer \(accessToken)"]
}
