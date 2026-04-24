import Foundation
import Moya
import Alamofire

enum AuthTarget {
    case login(LoginRequest)
    case me
}

extension AuthTarget: TargetType {

    var baseURL: URL {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .login:
            return "/users/login/"
        case .me:
            return "/users/me/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return Moya.Method.post
        case .me:
            return Moya.Method.get
        }
    }

    var task: Task {
        switch self {
        case .login(let request):
            return .requestJSONEncodable(request)
        case .me:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        if case .me = self,
           let accessToken = AuthTokenStore.shared.accessToken,
           !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        return headers
    }
}
