//
//  MyMenuRowView.swift
//  NSG
//
//  Created by hawon on 3/26/26.
//
import UIKit
import SnapKit
import Then

final class MyMenuRowView: UIButton {

    private let iconImageView: UIImageView
    private let menuTitleLabel = UILabel().then {
        $0.font = .style(.body1)
        $0.textColor = .black800
        $0.isUserInteractionEnabled = false
    }

    init(symbolName: String, title: String) {
        self.iconImageView = UIImageView(
            image: UIImage(named: symbolName)
        )

        super.init(frame: .zero)

        backgroundColor = .black50
        layer.cornerRadius = 8
        clipsToBounds = true
        contentHorizontalAlignment = .leading

        iconImageView.tintColor = .black800
        iconImageView.isUserInteractionEnabled = false
        menuTitleLabel.text = title

        addSubview(iconImageView)
        addSubview(menuTitleLabel)

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        menuTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
