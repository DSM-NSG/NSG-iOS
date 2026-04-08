//
//  WriteTextView.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit
import Then
import SnapKit

final class WriteTextView: UIView, UITextViewDelegate {

    var onTextChanged: (() -> Void)?
    var text: String { textView.textColor == .lightGray ? "" : (textView.text ?? "") }

    private let maxLength: Int
    private let placeholder: String

    private let textView = UITextView().then {
        $0.font = .style(.body3)
        $0.backgroundColor = UIColor.black50
        $0.layer.cornerRadius = 8
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        $0.textColor = .lightGray
    }

    private let countLabel = UILabel().then {
        $0.font = .style(.body4)
        $0.textColor = UIColor.black800
        $0.textAlignment = .right
    }

    init(placeholder: String, maxLength: Int = 1000) {
        self.placeholder = placeholder
        self.maxLength = maxLength
        super.init(frame: .zero)
        textView.text = placeholder
        textView.textColor = .lightGray
        textView.delegate = self
        updateCountLabel()
        addSubview(textView)
        addSubview(countLabel)
        textView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(countLabel.snp.top).offset(-4)
        }
        countLabel.snp.makeConstraints {
            $0.right.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    private func updateCountLabel() {
        let count = textView.textColor == .lightGray ? 0 : (textView.text?.count ?? 0)
        countLabel.text = "\(count)/\(maxLength)"
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = UIColor.black800
            onTextChanged?()
        }
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.orange500.cgColor
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
        onTextChanged?()
        textView.layer.borderWidth = 0
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard textView.textColor != .lightGray else { return true }
        let current = textView.text ?? ""
        guard let range = Range(range, in: current) else { return true }
        return current.replacingCharacters(in: range, with: text).count <= maxLength
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == .lightGray { return }
        updateCountLabel()
        onTextChanged?()
    }
}
