//
//  LatestPostCardView.swift
//  NSG
//
//  Created by hawon on 3/26/26.
//
import UIKit
import SnapKit
import Then

public final class LatestPostCell: UICollectionViewCell {

    static let identifier = "LatestPostCell"

    private let cardView = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
    }

    private let titleLabel = UILabel().then {
        $0.font = .style(.header3)
        $0.textColor = .black800
        $0.numberOfLines = 1
    }

    private let contentLabel = UILabel().then {
        $0.font = .style(.body3)
        $0.textColor = .black800
        $0.numberOfLines = 1
    }

    private let chip = PostCategoryBadge(title: "")
    private let reactionView = PostReactionView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        [titleLabel, contentLabel, chip, reactionView].forEach { cardView.addSubview($0) }

        cardView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.trailing.equalToSuperview().inset(11)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(11)
        }

        chip.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(11)
            $0.top.equalTo(contentLabel.snp.bottom).offset(7)
            $0.bottom.equalToSuperview().inset(10)
        }

        reactionView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(chip)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with post: SharePost) {
        titleLabel.text = post.title
        contentLabel.text = post.content
        chip.text = post.category
    }
}
