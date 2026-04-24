//
//  CommentService.swift
//  NSG
//
//  Created by Codex on 4/16/26.
//
import Foundation

struct CreateCommentRequest: Codable {
    let content: String
    let isAnonymous: Bool

    enum CodingKeys: String, CodingKey {
        case content
        case isAnonymous = "is_anonymous"
    }
}

struct CreateCommentResponse: Decodable {
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
        content = (try? container.decode(String.self, forKey: .content)) ?? ""
        isAnonymous = container.decodeFlexibleBool(forKey: .isAnonymous)
        createdAt = try? container.decode(String.self, forKey: .createdAt)

        if let authorString = try? container.decode(String.self, forKey: .author) {
            author = authorString
        } else if let authorObject = try? container.decode(TipAuthor.self, forKey: .author) {
            if authorObject.anonymousNumber != nil {
                author = "익명"
                return
            }
            let baseName = authorObject.name ?? "익명"
            if let cohort = authorObject.cohort {
                author = "\(baseName) \(cohort)기"
            } else if let grade = authorObject.grade {
                author = "\(baseName) \(grade)기"
            } else {
                author = baseName
            }
        } else {
            author = "익명"
        }
    }
}

enum CommentServiceError: Error {
    case invalidBaseURL
    case invalidResponse
    case missingToken
    case server(statusCode: Int)
}

protocol CommentServicing {
    func createComment(postID: String, request: CreateCommentRequest) async throws -> CreateCommentResponse
    func createReply(postID: String, commentID: String, request: CreateCommentRequest) async throws -> CreateCommentResponse
}

final class CommentService: CommentServicing {

    static let shared = CommentService()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createComment(postID: String, request: CreateCommentRequest) async throws -> CreateCommentResponse {
        let endpoint = "posts/\(postID)/comments/"
        return try await sendCreateRequest(endpoint: endpoint, request: request)
    }

    func createReply(postID: String, commentID: String, request: CreateCommentRequest) async throws -> CreateCommentResponse {
        let endpoint = "posts/\(postID)/comments/\(commentID)/replies/"
        return try await sendCreateRequest(endpoint: endpoint, request: request)
    }

    private func sendCreateRequest(endpoint: String, request: CreateCommentRequest) async throws -> CreateCommentResponse {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "NSG_API_BASE_URL") as? String,
              let baseURL = URL(string: baseURLString) else {
            throw CommentServiceError.invalidBaseURL
        }

        guard let accessToken = AuthTokenStore.shared.accessToken, !accessToken.isEmpty else {
            throw CommentServiceError.missingToken
        }

        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw CommentServiceError.invalidBaseURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CommentServiceError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw CommentServiceError.server(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(CreateCommentResponse.self, from: data)
    }
}

private extension KeyedDecodingContainer {
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
}
