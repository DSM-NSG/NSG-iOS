//
//  TipSeletedViewController.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import SnapKit
import Then

class TipSeletedViewController: UIViewController {

    private let titleLabel = UILabel().then {
        $0.text = "꿀팁 작성"
        $0.font = .style(.header1)
        $0.textColor = .black800
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background

        addView()
        setLayout()
    }

    private func addView() {
        view.addSubview(titleLabel)
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            $0.leading.equalToSuperview().inset(24)
        }
    }
}
