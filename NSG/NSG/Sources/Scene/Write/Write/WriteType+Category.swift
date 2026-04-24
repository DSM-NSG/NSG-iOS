import Foundation

extension TipType {
    var requiresMajorSelection: Bool {
        self == .major
    }

    var apiCategory: String {
        switch self {
        case .location:
            return "PLACE"
        case .dormitory:
            return "DORM_LIFE"
        case .school:
            return "SCHOOL_LIFE"
        case .major:
            return "SCHOOL_LIFE"
        case .etc:
            return "ETC"
        }
    }
}

extension LocationCategory {
    var placeAPICategory: String {
        switch self {
        case .cafe:
            return "CAFE"
        case .pcRoom:
            return "PC_ROOM"
        case .karaoke:
            return "KARAOKE"
        case .restaurant:
            return "RESTAURANT"
        case .etc:
            return "ETC"
        }
    }
}
