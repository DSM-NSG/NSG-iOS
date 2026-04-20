import Foundation
import Moya
import Alamofire

enum TipTarget {
    case list(category: String?, page: Int?, search: String?)
    case detail(id: String)
    case create(CreateTipRequest)
    case toggleLike(postID: String)
}

extension TipTarget: TargetType {

    var baseURL: URL {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .list:
            return "/posts/tips/"
        case .detail(let id):
            return "/posts/tips/\(id)/"
        case .create:
            return "/posts/tips/create/"
        case .toggleLike(let postID):
            return "/posts/\(postID)/like/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list, .detail:
            return Moya.Method.get
        case .create, .toggleLike:
            return Moya.Method.post
        }
    }

    var task: Task {
        switch self {
        case .list(let category, let page, let search):
            var params: [String: Any] = [:]
            if let category, !category.isEmpty {
                params["category"] = category
            }
            if let page {
                params["page"] = page
            }
            if let search, !search.isEmpty {
                params["search"] = search
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .detail:
            return .requestPlain
        case .create(let request):
            return .requestJSONEncodable(request)
        case .toggleLike:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = [
            "Accept": "application/json"
        ]

        if case .create = self {
            headers["Content-Type"] = "application/json"
        }

        if let accessToken = AuthTokenStore.shared.accessToken, !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        return headers
    }
}
