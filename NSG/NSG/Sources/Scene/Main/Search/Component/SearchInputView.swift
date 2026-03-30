//
//  SearchInputView.swift
//  NSG
//
//  Created by hawon on 3/30/26.
//
import UIKit
import SnapKit
import Then

final class SearchInputView: UIView {

    var onBeginEditing: (() -> Void)?
    var onEndEditing: (() -> Void)?
    var onTextChanged: ((String) -> Void)?

    var currentText: String {
        textField.text ?? ""
    }

    var isEditingText: Bool {
        textField.isEditing
    }

    private let textField = UITextField().then {
        $0.font = .style(.body3)
        $0.textColor = .black800
        $0.tintColor = .orange500
        $0.returnKeyType = .search
        $0.attributedPlaceholder = NSAttributedString(
            string: "키워드 혹은 찾고싶은 검색어로 입력해주세요.",
            attributes: [.foregroundColor: UIColor.black400]
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black50
        layer.cornerRadius = 8

        addSubview(textField)
        textField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }

        textField.addTarget(self, action: #selector(handleBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(handleEndEditing), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFocused(_ isFocused: Bool) {
        layer.borderWidth = isFocused ? 1 : 0
        layer.borderColor = isFocused ? UIColor.orange500.cgColor : nil
    }

    func setText(_ text: String) {
        textField.text = text
    }

    @objc
    private func handleBeginEditing() {
        onBeginEditing?()
    }

    @objc
    private func handleEndEditing() {
        onEndEditing?()
    }

    @objc
    private func handleTextChanged() {
        onTextChanged?(textField.text ?? "")
    }
}
