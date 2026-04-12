//
//  NSGPopupView.swift
//  NSG
//
//  Created by hawon on 4/12/26.
//
import UIKit
import SnapKit
import Then

final class NSGPopupView: UIView {

    private let cancelAction: (() -> Void)?
    private let confirmAction: (() -> Void)?

    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    private let popupContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = .style(.header1)
        $0.textColor = .black800
        $0.numberOfLines = 0
    }

    private let messageLabel = UILabel().then {
        $0.font = .style(.body1)
        $0.textColor = .black800
        $0.numberOfLines = 0
    }

    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    private lazy var cancelButton = UIButton(type: .system).then {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .style(.header2)
        $0.backgroundColor = .black300
        $0.layer.cornerRadius = 8
        $0.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }

    private lazy var confirmButton = UIButton(type: .system).then {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .style(.header2)
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 8
        $0.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    }

    init(
        title: String,
        message: String,
        cancelButtonTitle: String,
        confirmButtonTitle: String,
        cancelAction: (() -> Void)? = nil,
        confirmAction: (() -> Void)? = nil
    ) {
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
        super.init(frame: .zero)

        titleLabel.text = title
        messageLabel.text = message
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        confirmButton.setTitle(confirmButtonTitle, for: .normal)

        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(dimView)
        addSubview(popupContainerView)

        [
            titleLabel,
            messageLabel,
            buttonStackView
        ].forEach { popupContainerView.addSubview($0) }

        [
            cancelButton,
            confirmButton
        ].forEach { buttonStackView.addArrangedSubview($0) }
    }

    private func setupLayout() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        popupContainerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(18)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(18)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(18)
        }
    }

    func show(in superview: UIView) {
        superview.addSubview(self)
        snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func dismiss() {
        removeFromSuperview()
    }

    @objc
    private func didTapCancelButton() {
        dismiss()
        cancelAction?()
    }

    @objc
    private func didTapConfirmButton() {
        dismiss()
        confirmAction?()
    }
}
