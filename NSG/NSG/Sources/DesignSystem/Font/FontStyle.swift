//
//  FontStyle.swift
//  NSG
//
//  Created by hawon on 3/9/26.
//
import UIKit


enum FontStyle {
    case header1
    case header2
    case header3
    case header4

    case body1
    case body2
    case body3
    case body4

    var font: UIFont {
            switch self {
            case .header1:
                return UIFont(name: "LINESeedSansKR-Bold", size: 20) ?? UIFont.systemFont(ofSize: 100)
            case .header2:
                return UIFont(name: "LINESeedSansKR-Bold", size: 16) ?? UIFont.systemFont(ofSize: 100)
            case .header3:
                return UIFont(name: "LINESeedSansKR-Bold", size: 14) ?? UIFont.systemFont(ofSize: 100)
            case .header4:
                return UIFont(name: "LINESeedSansKR-Bold", size: 12) ?? UIFont.systemFont(ofSize: 100)

            case .body1:
                return UIFont(name: "LINESeedSansKR-Regular", size: 16) ?? UIFont.systemFont(ofSize: 100)
            case .body2:
                return UIFont(name: "LINESeedSansKR-Regular", size: 14) ?? UIFont.systemFont(ofSize: 100)
            case .body3:
                return UIFont(name: "LINESeedSansKR-Regular", size: 12) ?? UIFont.systemFont(ofSize: 100)
            case .body4:
                return UIFont(name: "LINESeedSansKR-Regular", size: 8) ?? UIFont.systemFont(ofSize: 100)
            }
        }
}

extension UIFont {
    static func style(_ style: FontStyle) -> UIFont {
        style.font
    }
}
