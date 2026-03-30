//
//  MyViewControll.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import SnapKit
import Then

final class MyViewController: UIViewController {

    private let profileCardView = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
    }

    private let profileImageView = UIView().then {
        $0.backgroundColor = .orange400
        $0.layer.cornerRadius = 25
    }

    private let nameLabel = UILabel().then {
        $0.text = "정지윤"
        $0.font = .style(.body1)
        $0.textColor = .black800
    }

    private let classLabel = UILabel().then {
        $0.text = "10기"
        $0.font = .style(.body1)
        $0.textColor = .black800
    }

    private lazy var logoutRow = MyMenuRowView(
        symbolName: "logout",
        title: "로그아웃"
    )

    private lazy var withdrawRow = MyMenuRowView(
        symbolName: "cancel",
        title: "회원탈퇴"
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configureUI()
    }

    private func addView() {
        [
            profileCardView,
            logoutRow,
            withdrawRow
        ].forEach { view.addSubview($0) }
        [
            profileImageView,
            nameLabel,
            classLabel
        ].forEach { profileCardView.addSubview($0) }

    }

    private func setLayout() {
        profileCardView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(104)
        }

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(50)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }

        classLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }

        logoutRow.snp.makeConstraints {
            $0.top.equalTo(profileCardView.snp.bottom).offset(45)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(70)
        }

        withdrawRow.snp.makeConstraints {
            $0.top.equalTo(logoutRow.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(70)
        }
    }

    private func configureUI() {
        view.backgroundColor = .background
    }
}

