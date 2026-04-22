import Foundation
import Moya
import Alamofire

enum TipTarget {
    case places(category: String?)
    case list(category: String?, page: Int?, search: String?)
    case majorPosts(majorID: String?, page: Int?, search: String?)
    case detail(id: String)
    case majorDetail(id: String)
    case majors
    case popularMajors
    case uploadImage(data: Data, fileName: String, mimeType: String)
    case createPlace(CreatePlaceRequest)
    case create(CreateTipRequest)
    case createMajor(CreateMajorPostRequest)
    case toggleLike(postID: String)
    case deleteTip(id: String)
    case deleteMajor(id: String)
}

extension TipTarget: TargetType {

    var baseURL: URL {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .places:
            return "/"
        case .list:
            return "/posts/tips/"
        case .majorPosts:
            return "/posts/major/"
        case .detail(let id):
            return "/posts/tips/\(id)/"
        case .majorDetail(let id):
            return "/posts/major/\(id)/"
        case .majors:
            return "/majors/"
        case .popularMajors:
            return "/majors/popular/"
        case .uploadImage:
            return "/images/upload/"
        case .createPlace:
            return "/"
        case .create:
            return "/posts/tips/create/"
        case .createMajor:
            return "/posts/major/create/"
        case .toggleLike(let postID):
            return "/posts/\(postID)/like/"
        case .deleteTip(let id):
            return "/posts/tips/\(id)/delete/"
        case .deleteMajor(let id):
            return "/posts/major/\(id)/delete/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list, .majorPosts, .detail, .majorDetail, .majors, .popularMajors, .places:
            return Moya.Method.get
        case .create, .createMajor, .toggleLike, .uploadImage, .createPlace:
            return Moya.Method.post
        case .deleteTip, .deleteMajor:
            return Moya.Method.delete
        }
    }

    var task: Task {
        switch self {
        case .places(let category):
            var params: [String: Any] = [:]
            if let category, !category.isEmpty {
                params["category"] = category
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
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
        case .majorPosts(let majorID, let page, let search):
            var params: [String: Any] = [:]
            if let majorID, !majorID.isEmpty {
                params["major_id"] = majorID
            }
            if let page {
                params["page"] = page
            }
            if let search, !search.isEmpty {
                params["search"] = search
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .detail, .majorDetail, .majors, .popularMajors:
            return .requestPlain
        case .uploadImage(let data, let fileName, let mimeType):
            let multipartData = MultipartFormData(
                provider: .data(data),
                name: "image",
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([multipartData])
        case .createPlace(let request):
            return .requestJSONEncodable(request)
        case .create(let request):
            return .requestJSONEncodable(request)
        case .createMajor(let request):
            return .requestJSONEncodable(request)
        case .toggleLike, .deleteTip, .deleteMajor:
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

        if case .createMajor = self {
            headers["Content-Type"] = "application/json"
        }

        if case .createPlace = self {
            headers["Content-Type"] = "application/json"
        }

        if let accessToken = AuthTokenStore.shared.accessToken, !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        return headers
    }
}
