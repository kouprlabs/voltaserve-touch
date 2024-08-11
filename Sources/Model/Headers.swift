import Foundation
import Alamofire

func headersWithAuthorization(_ accessToken: String) -> HTTPHeaders {
    ["Authorization": "Bearer \(accessToken)"]
}
