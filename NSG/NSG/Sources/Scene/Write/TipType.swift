//
//  TipType.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit

enum TipType: CaseIterable {
    case location
    case dormitory
    case school
    case major
    case etc

    var navigationTitle: String {
        switch self {
        case .location:   return "장소 꿀팁 공유하기"
        case .dormitory:  return "기숙사 꿀팁 공유하기"
        case .school:     return "대마고 꿀팁 공유하기"
        case .major:      return "전공 꿀팁 공유하기"
        case .etc:        return "기타 꿀팁 공유하기"
        }
    }

    var iconName: String {
        switch self {
        case .location:  return "locationIcon"
        case .dormitory: return "dormitoryIcon"
        case .school:    return "schoolIcon"
        case .major:     return "majorIcon"
        case .etc:       return "etcIcon"
        }
    }

    var previewImageName: String {
        switch self {
        case .location:  return "location"
        case .dormitory: return "dormitory"
        case .school:    return "school"
        case .major:     return "major"
        case .etc:       return "etc"
        }
    }

    var buttonText: String {
        switch self {
        case .location:  return "장소"
        case .dormitory: return "기숙사 꿀팁"
        case .school:    return "대마고 꿀팁"
        case .major:     return "전공 꿀팁"
        case .etc:       return "기타 꿀팁"
        }
    }

    /// 장소 타입만 카테고리 선택 UI 필요
    var requiresCategorySelection: Bool {
        return self == .location
    }
}

// MARK: - LocationCategory

enum LocationCategory: CaseIterable {
    case cafe
    case pcRoom
    case karaoke
    case restaurant
    case etc

    var title: String {
        switch self {
        case .cafe:       return "카페"
        case .pcRoom:     return "PC방"
        case .karaoke:    return "노래방"
        case .restaurant: return "맛집"
        case .etc:        return "기타"
        }
    }

    /// 스크린샷 기준 각 칩의 고유 배경색
    var color: UIColor {
        switch self {
        case .cafe:       return UIColor(hex: "#7D6B5E") // 브라운
        case .pcRoom:     return UIColor(hex: "#4A7FC1") // 블루
        case .karaoke:    return UIColor(hex: "#9B3FA8") // 퍼플
        case .restaurant: return UIColor.orange500       // 오렌지
        case .etc:        return UIColor(hex: "#6B7280") // 그레이
        }
    }
}

// MARK: - UIColor hex 편의 이니셜라이저

extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat( rgb & 0x0000FF)         / 255.0,
            alpha: 1.0
        )
    }
}
