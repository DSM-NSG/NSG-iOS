//
//  LoginViewController.swift
//  NSG
//
//  Created by hawon on 3/11/26.
//
import UIKit
import SnapKit
import Then

class LoginViewController: UIViewController {

    let idTextField = NSGTextField(title: "DAS 아이디", placeholder: "아이디를 입력해주세요.")
    let pwdTextField = NSGTextField(title: "비밀번호", placeholder: "비밀번호를 입력해주세요.", isSecure: true)
    let loginButton = NSGButton(title: "로그인", color: .orange400)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configuration()

    }

    private func addView() {
        let stackView = UIStackView(arrangedSubviews: [idTextField, pwdTextField])
        stackView.axis = .vertical
        stackView.spacing = 46
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        view.addSubview(loginButton)
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
        }
    }

    private func setLayout() {
        idTextField.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        pwdTextField.snp.makeConstraints {
            $0.height.equalTo(52)
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
