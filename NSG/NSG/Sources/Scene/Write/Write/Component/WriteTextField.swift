//
//  WriteTextField.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit
import SnapKit
import Then

final class NSGSingleTextField: UIView {

    var onTextChanged: (() -> Void)?
    var text: String { textField.text ?? "" }

    private let textField = UITextField().then {
        $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor.black50
        $0.layer.cornerRadius = 8
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        $0.leftViewMode = .always
    }

    init(placeholder: String) {
        super.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        addSubview(textField)
        textField.snp.makeConstraints { $0.edges.equalToSuperview() }
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func textDidChange() { onTextChanged?() }

    @objc private func didBeginEditing() {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.orange500.cgColor
    }

    @objc private func didEndEditing() {
        textField.layer.borderWidth = 0
    }
}
