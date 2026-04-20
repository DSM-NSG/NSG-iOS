import Foundation

final class AuthTokenStore {

    static let shared = AuthTokenStore()

    private enum Key {
        static let accessToken = "nsg.auth.accessToken"
        static let refreshToken = "nsg.auth.refreshToken"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var accessToken: String? {
        userDefaults.string(forKey: Key.accessToken)
    }

    var refreshToken: String? {
        userDefaults.string(forKey: Key.refreshToken)
    }

    var isLoggedIn: Bool {
        guard let accessToken,
              let refreshToken else {
            return false
        }

        return !accessToken.isEmpty && !refreshToken.isEmpty
    }

    func save(accessToken: String, refreshToken: String) {
        userDefaults.set(accessToken, forKey: Key.accessToken)
        userDefaults.set(refreshToken, forKey: Key.refreshToken)
    }

    func clear() {
        userDefaults.removeObject(forKey: Key.accessToken)
        userDefaults.removeObject(forKey: Key.refreshToken)
    }
}
