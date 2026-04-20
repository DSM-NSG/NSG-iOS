import Foundation
import Moya

enum AuthServiceError: LocalizedError {
    case invalidBaseURL

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "서버 주소(NSG_API_BASE_URL)가 올바르지 않습니다."
        }
    }
}

protocol AuthServicing {
    func login(accountID: String, password: String) async throws -> LoginResponse
}

@MainActor
final class AuthService: AuthServicing {

    static let shared = AuthService()

    private let provider: MoyaProvider<AuthTarget>

    init(provider: MoyaProvider<AuthTarget>) {
        self.provider = provider
    }

    convenience init() {
        let provider = MoyaProvider<AuthTarget>(plugins: [MoyaLoggingPlugin()])
        self.init(provider: provider)
    }

    func login(accountID: String, password: String) async throws -> LoginResponse {
        if APIConfig.baseURL.absoluteString == "https://invalid.local" {
            throw AuthServiceError.invalidBaseURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.login(LoginRequest(accountID: accountID, password: password))) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: filteredResponse.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
