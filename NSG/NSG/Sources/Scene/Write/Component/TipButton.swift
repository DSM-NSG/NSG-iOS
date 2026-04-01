//
//  TipButton.swift
//  NSG
//
//  Created by hawon on 3/30/26.
//
import UIKit
import SnapKit
import Then

final class TipButton: UIButton {

    private let containerView = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
        $0.isUserInteractionEnabled = false
        $0.clipsToBounds = true
    }

    private let iconImageView = UIImageView().then {
        $0.tintColor = .black800
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }

    private let textLabelView = UILabel().then {
        $0.font = .style(.header2)
        $0.textColor = .black800
        $0.numberOfLines = 1
        $0.isUserInteractionEnabled = false
    }

    private let shareLabel = UILabel().then {
        $0.text = "공유하기"
        $0.font = .style(.header2)
        $0.textColor = .black800
        $0.isUserInteractionEnabled = false
    }

    private lazy var infoStackView = UIStackView(arrangedSubviews: [iconImageView, textLabelView]).then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 5
        $0.isUserInteractionEnabled = false
    }

    private let previewImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 8
    }

    init(icon: UIImage?, previewImage: UIImage?, text: String) {
        super.init(frame: .zero)

        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        previewImageView.image = previewImage
        textLabelView.text = text

        setUI()
        addView()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        backgroundColor = .clear
        adjustsImageWhenHighlighted = false
    }

    private func addView() {
        addSubview(containerView)
        [infoStackView, shareLabel, previewImageView].forEach { containerView.addSubview($0) }
    }

    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(90)
        }

        infoStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview().offset(-14)
            $0.trailing.lessThanOrEqualTo(previewImageView.snp.leading).offset(-16)
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(28)
        }

        shareLabel.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(2)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.lessThanOrEqualTo(previewImageView.snp.leading).offset(-16)
        }

        previewImageView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(164)
        }
    }
}
