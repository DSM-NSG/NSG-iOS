import Foundation
import Moya
import Alamofire

enum AuthTarget {
    case login(LoginRequest)
}

extension AuthTarget: TargetType {

    var baseURL: URL {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .login:
            return "/users/login/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return Moya.Method.post
        }
    }

    var task: Task {
        switch self {
        case .login(let request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
