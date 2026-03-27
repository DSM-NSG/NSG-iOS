//
//  LatestPostCardView.swift
//  NSG
//
//  Created by hawon on 3/26/26.
//
import UIKit
import SnapKit
import Then

public final class LatestPostCardView: UIView {

    init(post: SharePost) {
        super.init(frame: .zero)

        backgroundColor = .black50
        layer.cornerRadius = 12

        let titleLabel = UILabel().then {
            $0.text = post.title
            $0.font = .style(.header2)
            $0.textColor = .black800
            $0.numberOfLines = 1
        }

        let contentLabel = UILabel().then {
            $0.text = post.content
            $0.font = .style(.body2)
            $0.textColor = .black500
            $0.numberOfLines = 1
        }

        let chip = PostCategoryBadge(title: post.category)
        let reactionView = PostReactionView()

        [titleLabel, contentLabel, chip, reactionView].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        chip.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(11)
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(11)
        }

        reactionView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(chip)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
