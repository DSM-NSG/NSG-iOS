import Foundation

struct LoginRequest: Encodable {
    let accountID: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case password
    }
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: LoginUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct LoginUser: Codable {
    let id: String
    let accountID: String
    let name: String
    let grade: Int
    let classNum: Int
    let num: Int

    enum CodingKeys: String, CodingKey {
        case id
        case accountID = "account_id"
        case name
        case grade
        case classNum = "class_num"
        case num
    }
}
