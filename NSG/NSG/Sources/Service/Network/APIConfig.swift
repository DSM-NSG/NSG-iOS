import Foundation

enum APIConfig {
    static var baseURL: URL {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "NSG_API_BASE_URL") as? String,
              let url = URL(string: baseURLString) else {
            assertionFailure("NSG_API_BASE_URL is missing or invalid in Info.plist")
            return URL(string: "https://invalid.local")!
        }

        return url
    }
}
