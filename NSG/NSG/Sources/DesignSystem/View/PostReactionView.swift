//
//  PostReactionView.swift
//  NSG
//
//  Created by hawon on 3/26/26.
//
import UIKit
import SnapKit
import Then

public final class PostReactionView: UIStackView {

    init() {
        super.init(frame: .zero)

        axis = .horizontal
        alignment = .center
        spacing = 6

        addArrangedSubview(makeReaction(symbolName: "heart", value: "15"))
        addArrangedSubview(makeReaction(symbolName: "coment", value: "15"))
    }

    private func makeReaction(symbolName: String, value: String) -> UIStackView {
        let icon = UIImageView().then {
            $0.image = UIImage(named: symbolName)
            $0.tintColor = .orange300
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { $0.size.equalTo(15) }
        }

        let label = UILabel().then {
            $0.text = value
            $0.font = .style(.body4)
            $0.textColor = .orange300
        }

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 3
        return stack
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

