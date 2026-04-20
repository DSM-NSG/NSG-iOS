//
//  LoginViewController.swift
//  NSG
//
//  Created by hawon on 3/11/26.
//
import UIKit
import SnapKit
import Then

@MainActor
class LoginViewController: UIViewController {

    let idTextField = NSGTextField(title: "DAS 아이디", placeholder: "아이디를 입력해주세요.")
    let pwdTextField = NSGTextField(title: "비밀번호", placeholder: "비밀번호를 입력해주세요.", isSecure: true)
    let loginButton = NSGButton(title: "로그인", color: .orange400)
    private var loginButtonBottomConstraint: Constraint?
    private let authService: AuthServicing

    init(authService: AuthServicing) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(authService: AuthService.shared)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        idTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwdTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc
    private func textFieldDidChange() {
        let id = idTextField.currentText().trimmingCharacters(in: .whitespacesAndNewlines)
        let password = pwdTextField.currentText().trimmingCharacters(in: .whitespacesAndNewlines)
        loginButton.isEnabled = !id.isEmpty && !password.isEmpty
    }

    @objc
    private func didTapLoginButton() {
        view.endEditing(true)
        login()
    }

    private func login() {
        let id = idTextField.currentText().trimmingCharacters(in: .whitespacesAndNewlines)
        let password = pwdTextField.currentText().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !password.isEmpty else { return }

        loginButton.isEnabled = false

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await authService.login(accountID: id, password: password)
                AuthTokenStore.shared.save(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                await MainActor.run {
                    AppRootNavigator.moveToMain()
                }
            } catch {
                await MainActor.run {
                    self.loginButton.isEnabled = true
                    self.presentLoginError(error)
                }
            }
        }
    }

    private func presentLoginError(_ error: Error) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
