//
//  PostCategoryBadge.swift
//  NSG
//
//  Created by Codex on 3/26/26.
//
import UIKit
import SnapKit

final class PostCategoryBadge: UILabel {

    init(title: String) {
        super.init(frame: .zero)

        text = title
        font = .style(.body4)
        textAlignment = .center
        textColor = .black50
        backgroundColor = .orange300
        layer.cornerRadius = 2
        clipsToBounds = true
        
        snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 42, height: 15))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
