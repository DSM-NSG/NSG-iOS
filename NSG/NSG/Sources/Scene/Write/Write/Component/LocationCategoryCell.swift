//
//  LocationCategoryCell.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit
import SnapKit
import Then

final class LocationCategoryCell: UICollectionViewCell {

    static let identifier = "LocationCategoryChipCell"

    private let label = UILabel().then {
        $0.font = .style(.body3)
        $0.textColor = .background
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.horizontalEdges.equalToSuperview().inset(15)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(category: LocationCategory, isSelected: Bool) {
        label.text = category.title
        // 선택 시 약간 어둡게, 미선택 시 원래 색
        contentView.backgroundColor = isSelected
            ? category.color.withAlphaComponent(0.6)
            : category.color
    }
}

