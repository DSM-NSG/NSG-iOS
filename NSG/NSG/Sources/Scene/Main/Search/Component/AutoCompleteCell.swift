//
//  AutoCompleteCell.swift
//  NSG
//
//  Created by hawon on 3/30/26.
//
import UIKit
import SnapKit
import Then

final class AutoCompleteCell: UITableViewCell {

    static let identifier = "AutoCompleteCell"

    private let titleLabel = UILabel().then {
        $0.font = .style(.body3)
        $0.textColor = .black500
        $0.numberOfLines = 1
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, keyword: String) {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.style(.body3),
                .foregroundColor: UIColor.black500
            ]
        )

        let nsText = text as NSString
        var searchRange = NSRange(location: 0, length: nsText.length)

        while !keyword.isEmpty {
            let foundRange = nsText.range(of: keyword, options: [], range: searchRange)
            guard foundRange.location != NSNotFound else { break }

            attributedString.addAttributes([
                .foregroundColor: UIColor.orange400,
                .font: UIFont.style(.body3)
            ], range: foundRange)

            let nextLocation = foundRange.location + foundRange.length
            searchRange = NSRange(location: nextLocation, length: nsText.length - nextLocation)
        }

        titleLabel.attributedText = attributedString
    }
}

