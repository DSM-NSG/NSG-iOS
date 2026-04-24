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
    let cohort: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case accountID = "account_id"
        case name
        case grade
        case classNum = "class_num"
        case num
        case cohort
    }

    private enum AlternateCodingKeys: String, CodingKey {
        case userID = "user_id"
    }

    init(
        id: String,
        accountID: String,
        name: String,
        grade: Int,
        classNum: Int,
        num: Int,
        cohort: Int?
    ) {
        self.id = id
        self.accountID = accountID
        self.name = name
        self.grade = grade
        self.classNum = classNum
        self.num = num
        self.cohort = cohort
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alternateContainer = try decoder.container(keyedBy: AlternateCodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id))
            ?? (try? alternateContainer.decode(String.self, forKey: .userID))
            ?? ""
        accountID = (try? container.decode(String.self, forKey: .accountID)) ?? ""
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        grade = (try? container.decode(Int.self, forKey: .grade)) ?? 0
        classNum = (try? container.decode(Int.self, forKey: .classNum)) ?? 0
        num = (try? container.decode(Int.self, forKey: .num)) ?? 0
        cohort = try? container.decode(Int.self, forKey: .cohort)
    }
}

struct MyProfileResponse: Decodable {
    let userID: String
    let grade: Int
    let classNum: Int
    let num: Int
    let cohort: Int

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case grade
        case classNum = "class_num"
        case num
        case cohort
    }
}
