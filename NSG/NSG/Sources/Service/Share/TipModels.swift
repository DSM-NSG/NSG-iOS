import Foundation

struct MajorCategory: Decodable, Equatable {
    let id: String
    let name: String
}

struct TipAuthor: Decodable {
    let grade: Int?
    let classNum: Int?
    let num: Int?
    let name: String?
    let anonymousNumber: Int?

    enum CodingKeys: String, CodingKey {
        case grade
        case classNum = "class_num"
        case num
        case name
        case anonymousNumber = "anonymous_number"
    }
}

struct CreateTipRequest: Encodable {
    let title: String
    let body: String
    let category: String
    let isAnonymous: Bool
    let placeID: String?
    let imageURLs: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case category
        case isAnonymous = "is_anonymous"
        case placeID = "place_id"
        case imageURLs = "image_urls"
    }
}

struct CreateMajorPostRequest: Encodable {
    let title: String
    let body: String
    let majorIDs: [String]
    let isAnonymous: Bool
    let imageURLs: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case majorIDs = "major_ids"
        case isAnonymous = "is_anonymous"
        case imageURLs = "image_urls"
    }
}

struct TipListResponseItem: Decodable {
    let id: String
    let author: String
    let title: String
    let body: String
    let category: String
    let likeCount: Int
    let isLiked: Bool
    let commentCount: Int
    let hasImages: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case title
        case body
        case category
        case likeCount = "like_count"
        case isLiked = "is_liked"
        case commentCount = "comment_count"
        case hasImages = "has_images"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        author = container.decodeFlexibleAuthor(forKey: .author)
        title = try container.decode(String.self, forKey: .title)
        body = (try? container.decode(String.self, forKey: .body)) ?? ""
        category = try container.decode(String.self, forKey: .category)
        likeCount = container.decodeFlexibleInt(forKey: .likeCount)
        isLiked = container.decodeFlexibleBool(forKey: .isLiked)
        commentCount = container.decodeFlexibleInt(forKey: .commentCount)
        hasImages = container.decodeFlexibleBool(forKey: .hasImages)
        createdAt = (try? container.decode(String.self, forKey: .createdAt)) ?? ""
    }
}

struct TipListPageResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [TipListResponseItem]
}

struct TipLikeToggleResponse: Decodable {
    let isLiked: Bool
    let likeCount: Int

    enum CodingKeys: String, CodingKey {
        case isLiked = "is_liked"
        case likeCount = "like_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isLiked = container.decodeFlexibleBool(forKey: .isLiked)
        likeCount = container.decodeFlexibleInt(forKey: .likeCount)
    }
}

struct TipDetailResponse: Decodable {
    struct Image: Decodable {
        let url: String
        let orderIndex: Int

        enum CodingKeys: String, CodingKey {
            case url
            case orderIndex = "order_index"
        }
    }

    struct Reply: Decodable {
        let id: String
        let author: String
        let content: String
        let isAnonymous: Bool
        let createdAt: String?

        enum CodingKeys: String, CodingKey {
            case id
            case author
            case content
            case isAnonymous = "is_anonymous"
            case createdAt = "created_at"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            author = container.decodeFlexibleAuthor(forKey: .author)
            content = (try? container.decode(String.self, forKey: .content)) ?? ""
            isAnonymous = container.decodeFlexibleBool(forKey: .isAnonymous)
            createdAt = try? container.decode(String.self, forKey: .createdAt)
        }
    }

    struct Comment: Decodable {
        let id: String
        let author: String
        let content: String
        let isAnonymous: Bool
        let createdAt: String?
        let replies: [Reply]

        enum CodingKeys: String, CodingKey {
            case id
            case author
            case content
            case isAnonymous = "is_anonymous"
            case createdAt = "created_at"
            case replies
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            author = container.decodeFlexibleAuthor(forKey: .author)
            content = (try? container.decode(String.self, forKey: .content)) ?? ""
            isAnonymous = container.decodeFlexibleBool(forKey: .isAnonymous)
            createdAt = try? container.decode(String.self, forKey: .createdAt)
            replies = (try? container.decode([Reply].self, forKey: .replies)) ?? []
        }
    }

    let id: String
    let author: String
    let title: String
    let body: String
    let category: String
    let place: String?
    let isAnonymous: Bool
    let likeCount: Int
    let isLiked: Bool
    let images: [Image]
    let commentCount: Int?
    let comments: [Comment]
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case title
        case body
        case category
        case place
        case isAnonymous = "is_anonymous"
        case likeCount = "like_count"
        case isLiked = "is_liked"
        case images
        case commentCount = "comment_count"
        case comments
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        author = container.decodeFlexibleAuthor(forKey: .author)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        category = try container.decode(String.self, forKey: .category)
        place = try? container.decode(String.self, forKey: .place)
        isAnonymous = container.decodeFlexibleBool(forKey: .isAnonymous)
        likeCount = container.decodeFlexibleInt(forKey: .likeCount)
        isLiked = container.decodeFlexibleBool(forKey: .isLiked)
        images = (try? container.decode([Image].self, forKey: .images)) ?? []
        if container.contains(.commentCount) {
            commentCount = container.decodeFlexibleInt(forKey: .commentCount)
        } else {
            commentCount = nil
        }
        comments = (try? container.decode([Comment].self, forKey: .comments)) ?? []
        createdAt = (try? container.decode(String.self, forKey: .createdAt)) ?? ""
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleInt(forKey key: K) -> Int {
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue
        }

        if let stringValue = try? decode(String.self, forKey: key), let intValue = Int(stringValue) {
            return intValue
        }

        return 0
    }

    func decodeFlexibleBool(forKey key: K) -> Bool {
        if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue
        }

        if let stringValue = try? decode(String.self, forKey: key) {
            return NSString(string: stringValue).boolValue
        }

        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue != 0
        }

        return false
    }

    func decodeFlexibleAuthor(forKey key: K) -> String {
        if let authorString = try? decode(String.self, forKey: key) {
            return authorString
        }

        if let authorObject = try? decode(TipAuthor.self, forKey: key) {
            if authorObject.anonymousNumber != nil {
                return "익명"
            }
            let baseName = authorObject.name ?? "익명"
            if let grade = authorObject.grade {
                return "\(baseName) \(grade)기"
            }
            return baseName
        }

        return "익명"
    }
}
