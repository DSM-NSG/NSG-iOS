import Foundation

final class AuthTokenStore {

    static let shared = AuthTokenStore()

    private enum Key {
        static let accessToken = "nsg.auth.accessToken"
        static let refreshToken = "nsg.auth.refreshToken"
        static let user = "nsg.auth.user"
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

    var currentUser: LoginUser? {
        guard let userData = userDefaults.data(forKey: Key.user) else {
            return nil
        }
        return try? JSONDecoder().decode(LoginUser.self, from: userData)
    }

    func save(accessToken: String, refreshToken: String) {
        userDefaults.set(accessToken, forKey: Key.accessToken)
        userDefaults.set(refreshToken, forKey: Key.refreshToken)
    }

    func saveSession(accessToken: String, refreshToken: String, user: LoginUser) {
        save(accessToken: accessToken, refreshToken: refreshToken)
        saveCurrentUser(user)
    }

    func saveCurrentUser(_ user: LoginUser) {
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: Key.user)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: Key.accessToken)
        userDefaults.removeObject(forKey: Key.refreshToken)
        userDefaults.removeObject(forKey: Key.user)
    }
}
