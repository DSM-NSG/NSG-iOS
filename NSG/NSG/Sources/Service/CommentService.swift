//
//  CommentService.swift
//  NSG
//
//  Created by Codex on 4/16/26.
//
import Foundation

struct CreateCommentRequest: Codable {
    let postTitle: String
    let content: String
    let isAnonymous: Bool
    let parentAuthor: String?
}

struct CreateCommentResponse: Codable {
    let id: String?
    let author: String?
    let content: String?
}

enum CommentServiceError: Error {
    case invalidBaseURL
    case invalidResponse
    case server(statusCode: Int)
}

protocol CommentServicing {
    func createComment(request: CreateCommentRequest) async throws -> CreateCommentResponse
}

final class CommentService: CommentServicing {

    static let shared = CommentService()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createComment(request: CreateCommentRequest) async throws -> CreateCommentResponse {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "NSG_API_BASE_URL") as? String,
              let baseURL = URL(string: baseURLString) else {
            throw CommentServiceError.invalidBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("comments")
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CommentServiceError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw CommentServiceError.server(statusCode: httpResponse.statusCode)
        }

        if data.isEmpty {
            return CreateCommentResponse(id: nil, author: nil, content: nil)
        }

        return try JSONDecoder().decode(CreateCommentResponse.self, from: data)
    }
}
