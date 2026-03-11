//
//  NSGButton.swift
//  NSG
//
//  Created by hawon on 3/9/26.
//
import UIKit

public class NSGButton: UIButton {

    init(title: String, color: UIColor) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        backgroundColor = color
        setTitleColor(.black900, for: .normal)

        titleLabel?.font = .style(.header1)

        layer.cornerRadius = 8
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
