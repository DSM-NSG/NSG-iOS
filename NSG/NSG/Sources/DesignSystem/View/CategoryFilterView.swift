//
//  CategoryFilterView.swift
//  NSG
//
//  Created by Codex on 3/30/26.
//
import UIKit
import SnapKit
import Then

final class CategoryFilterView: UIView {

    var onSelectCategory: ((String?) -> Void)?

    private let categories = ["장소", "기숙사", "대마고", "기타"]

    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillProportionally
    }

    private var buttons: [CategoryChipButton] = []
    private var selectedCategory: String?

    override init(frame: CGRect) {
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bindContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelectedCategory(_ category: String?) {
        selectedCategory = category
        updateSelection()
    }

    private func bindContent() {
        buttons = categories.map { category in
            let button = CategoryChipButton(title: category)
            button.addTarget(self, action: #selector(didTapCategoryButton(_:)), for: .touchUpInside)
            return button
        }

        buttons.forEach { stackView.addArrangedSubview($0) }
    }

    private func updateSelection() {
        buttons.forEach { button in
            button.isSelected = button.chipTitle == selectedCategory
        }
    }

    @objc
    private func didTapCategoryButton(_ sender: CategoryChipButton) {
        let tappedTitle = sender.chipTitle
        selectedCategory = selectedCategory == tappedTitle ? nil : tappedTitle
        updateSelection()
        onSelectCategory?(selectedCategory)
    }
}
