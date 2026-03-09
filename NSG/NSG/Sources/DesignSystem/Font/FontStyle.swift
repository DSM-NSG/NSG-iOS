//
//  FontStyle.swift
//  NSG
//
//  Created by hawon on 3/9/26.
//
import SwiftUI


enum FontStyle {
    case header2
    case header3
    case header4

    case body1
    case body2
    case body3
    case body4

    var font: Font {
            switch self {
            case .header2:
                return .custom("LINESeedSansKR-Bold", size: 16)
            case .header3:
                return .custom("LINESeedSansKR-Bold", size: 14)
            case .header4:
                return .custom("LINESeedSansKR-Bold", size: 12)

            case .body1:
                return .custom("LINESeedSansKR-Regular", size: 16)
            case .body2:
                return .custom("LINESeedSansKR-Regular", size: 14)
            case .body3:
                return .custom("LINESeedSansKR-Regular", size: 12)
            case .body4:
                return .custom("LINESeedSansKR-Regular", size: 8)
            }
        }
}

extension Font {
    static func style(_ style: FontStyle) -> Font {
        style.font
    }
}
