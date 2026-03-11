import UIKit
import SnapKit
import Then

class NSGTextField: UIView {
    
    private var isPasswordVisible = false
    private let isSecure: Bool

    public let titleLabel = UILabel().then {
        $0.font = .style(.body3)
        $0.textColor = UIColor.black800
    }
    public let textField = UITextField().then {
        $0.font = .style(.body3)
        $0.backgroundColor = UIColor.black50
        $0.layer.cornerRadius = 8
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 0))
        $0.leftViewMode = .always
    }
    
    private lazy var showPasswordButton = UIButton().then {
        $0.setImage(UIImage(named: "eyeOff"), for: .normal)
        $0.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
    
    init(title: String, placeholder: String, isSecure: Bool = false) {
        self.titleLabel.text = title
        self.isSecure = isSecure
        super.init(frame: .zero)
        
        configureTextField(title: title, placeholder: placeholder)
        layout()
        addTextFieldTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextField(title: String, placeholder: String) {
        textField.isSecureTextEntry = isSecure
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        
        if isSecure {
            textField.rightView = showPasswordButton
            textField.rightViewMode = .always
        }
    }
    
    private func addTextFieldTargets() {
        textField.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }
    
    private func layout() {
        addSubview(titleLabel)
        addSubview(textField)

        titleLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview()
        }
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(52)
        }
    }
    
    @objc private func didBeginEditing() {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.orange500.cgColor
    }
    
    @objc private func didEndEditing() {
        textField.layer.borderWidth = 0
    }
    
    @objc private func togglePasswordVisibility() {
        guard isSecure else { return }
        isPasswordVisible.toggle()
        textField.isSecureTextEntry = !isPasswordVisible
        showPasswordButton.setImage(UIImage(named: isPasswordVisible ? "eyeOpen" : "eyeOff"), for: .normal)
    }
    
    public func currentText() -> String {
        return textField.text ?? ""
    }
}
