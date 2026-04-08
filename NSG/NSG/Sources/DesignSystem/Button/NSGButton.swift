//
//  NSGButton.swift
//  NSG
//
//  Created by hawon on 3/9/26.
//
import UIKit

public class NSGButton: UIButton {

    private let enabledColor: UIColor
    private let disabledColor: UIColor = .black100

    init(title: String, color: UIColor) {
        self.enabledColor = color
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        backgroundColor = disabledColor
        setTitleColor(.black400, for: .normal)

        titleLabel?.font = .style(.header1)

        layer.cornerRadius = 8
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 52).isActive = true

        updateStyle()
    }

    public override var isEnabled: Bool {
        didSet {
            updateStyle()
        }
    }

    private func updateStyle() {
        if isEnabled {
            backgroundColor = enabledColor
            setTitleColor(.white, for: .normal)
        } else {
            backgroundColor = disabledColor
            setTitleColor(.black400, for: .normal)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
