//
//  CategoryChipButton.swift
//  NSG
//
//  Created by hawon on 3/26/26.
//
import UIKit
import SnapKit
import Then

public final class CategoryChipButton: UIButton {

    let chipTitle: String

    init(title: String) {
        self.chipTitle = title
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        configuration = makeConfiguration(backgroundColor: .orange300)
        configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = self.makeConfiguration(
                backgroundColor: button.isSelected ? .orange400 : .orange300
            )
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeConfiguration(backgroundColor: UIColor) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        var container = AttributeContainer()
        container.font = .style(.body3)

        configuration.attributedTitle = AttributedString(chipTitle, attributes: container)
        configuration.baseForegroundColor = .black800
        configuration.background.backgroundColor = backgroundColor
        configuration.background.cornerRadius = 4
        configuration.cornerStyle = .fixed
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
        return configuration
    }
}
