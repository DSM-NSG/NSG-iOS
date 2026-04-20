import Foundation
import Moya

protocol TipServicing {
    func listTips(category: String?, page: Int?, search: String?) async throws -> [SharePost]
    func tipDetail(id: String) async throws -> SharePost
    func createTip(request: CreateTipRequest) async throws -> SharePost
}

@MainActor
final class TipService: TipServicing {

    static let shared = TipService()

    private let provider: MoyaProvider<TipTarget>

    init(provider: MoyaProvider<TipTarget>) {
        self.provider = provider
    }

    convenience init() {
        let provider = MoyaProvider<TipTarget>(plugins: [MoyaLoggingPlugin()])
        self.init(provider: provider)
    }

    func listTips(category: String?, page: Int?, search: String?) async throws -> [SharePost] {
        let apiCategory = mapCategoryToAPI(category)
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.list(category: apiCategory, page: page, search: search)) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let decoder = JSONDecoder()
                        let posts: [SharePost]

                        if let paged = try? decoder.decode(TipListPageResponse.self, from: filteredResponse.data) {
                            posts = paged.results.map(Self.mapListItemToSharePost)
                        } else {
                            let decoded = try decoder.decode([TipListResponseItem].self, from: filteredResponse.data)
                            posts = decoded.map(Self.mapListItemToSharePost)
                        }
                        continuation.resume(returning: posts)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func tipDetail(id: String) async throws -> SharePost {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.detail(id: id)) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let decoded = try JSONDecoder().decode(TipDetailResponse.self, from: filteredResponse.data)
                        continuation.resume(returning: Self.mapDetailToSharePost(decoded))
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func createTip(request: CreateTipRequest) async throws -> SharePost {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.create(request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let decoder = JSONDecoder()

                        if let decoded = try? decoder.decode(TipDetailResponse.self, from: filteredResponse.data) {
                            continuation.resume(returning: Self.mapDetailToSharePost(decoded))
                        } else {
                            // 생성 성공(2xx)인데 응답 스키마가 달라도 작성 플로우는 성공으로 처리
                            continuation.resume(
                                returning: SharePost(
                                    title: request.title,
                                    content: request.body,
                                    category: Self.mapCategoryFromAPI(request.category)
                                )
                            )
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func mapListItemToSharePost(_ item: TipListResponseItem) -> SharePost {
        SharePost(
            id: item.id,
            author: item.author,
            title: item.title,
            content: "작성자: \(item.author)",
            category: mapCategoryFromAPI(item.category),
            likeCount: item.likeCount,
            commentCount: item.commentCount,
            hasImages: item.hasImages,
            createdAt: item.createdAt
        )
    }

    private static func mapDetailToSharePost(_ detail: TipDetailResponse) -> SharePost {
        SharePost(
            id: detail.id,
            author: detail.author,
            title: detail.title,
            content: detail.body,
            category: mapCategoryFromAPI(detail.category),
            likeCount: detail.likeCount,
            commentCount: 0,
            hasImages: !detail.images.isEmpty,
            createdAt: detail.createdAt,
            place: detail.place,
            isAnonymous: detail.isAnonymous,
            isLiked: detail.isLiked,
            imageURLs: detail.images
                .sorted { $0.orderIndex < $1.orderIndex }
                .map(\.url)
        )
    }

    private func mapCategoryToAPI(_ category: String?) -> String? {
        switch category {
        case "장소":
            return "PLACE"
        case "기숙사":
            return "DORM_LIFE"
        case "대마고":
            return "SCHOOL_LIFE"
        case "기타":
            return "ETC"
        default:
            return nil
        }
    }

    private static func mapCategoryFromAPI(_ category: String) -> String {
        switch category {
        case "PLACE":
            return "장소"
        case "DORM_LIFE", "DORMITORY":
            return "기숙사"
        case "SCHOOL_LIFE", "DAEMAGO":
            return "대마고"
        case "ETC":
            return "기타"
        default:
            return category
        }
    }
}
