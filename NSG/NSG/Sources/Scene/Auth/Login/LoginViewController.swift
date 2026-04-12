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
    private var loginButtonBottomConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configuration()
        enableKeyboardDismissOnTap()
        if let loginButtonBottomConstraint {
            bindKeyboard(to: loginButtonBottomConstraint, defaultInset: 56)
        }

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
            loginButtonBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56).constraint
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    private func configuration() {
        view.backgroundColor = .background
        loginButton.isEnabled = false
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }

    @objc
    private func didTapLoginButton() {
        let popupView = NSGPopupView(
            title: "로그인",
            message: "입력한 계정으로 로그인하시겠습니까?",
            cancelButtonTitle: "취소",
            confirmButtonTitle: "로그인",
            confirmAction: { [weak self] in
                self?.view.endEditing(true)
                // TODO: 실제 로그인 API 연결
            }
        )
        popupView.show(in: view)
    }
}
