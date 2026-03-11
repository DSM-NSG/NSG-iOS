//
//  ViewController.swift
//  NSG
//
//  Created by hawon on 3/9/26.
//

import UIKit
import Then
import SnapKit

class SplashViewController: UIViewController {

    let logoImage = UIImageView().then {
        $0.image = UIImage(named: "logo")
    }

    let loginButton = NSGButton(title: "로그인", color: .orange400)

    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configuration()
        
    }

    private func addView()  {
        [
            logoImage,
            loginButton
        ].forEach { view.addSubview($0) }
    }

    private func setLayout() {
        logoImage.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        loginButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(56)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
     }

    private func configuration() {
        view.backgroundColor = .background
    }

}

