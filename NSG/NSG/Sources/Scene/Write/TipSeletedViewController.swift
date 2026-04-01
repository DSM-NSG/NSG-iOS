//
//  TipSeletedViewController.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import SnapKit
import Then

class TipSeletedViewController: UIViewController {

    private struct TipItem {
        let iconName: String
        let previewImage: String
        let text: String
    }

    private let titleLabel = UILabel().then {
        $0.text = "꿀팁 작성"
        $0.font = .style(.header1)
        $0.textColor = .black800
    }

    private let scrollView = UIScrollView()

    private let contentView = UIView()

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }

    private lazy var tipItems: [TipItem] = [
        TipItem(
            iconName: "locationIcon",
            previewImage: "location",
            text: "장소"
        ),
        TipItem(
            iconName: "dormitoryIcon",
            previewImage: "dormitory",
            text: "기숙사 꿀팁"
        ),
        TipItem(
            iconName: "schoolIcon",
            previewImage: "school",
            text: "대마고 꿀팁"
        ),
        TipItem(
            iconName: "majorIcon",
            previewImage: "major",
            text: "전공 꿀팁"
        ),
        TipItem(
            iconName: "etcIcon",
            previewImage: "etc",
            text: "기타 꿀팁"
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background

        addView()
        setLayout()
    }

    private func addView() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        tipItems
            .map { TipButton(icon: UIImage(named: $0.iconName), previewImage: UIImage(named: $0.previewImage), text: $0.text) }
            .forEach { stackView.addArrangedSubview($0) }
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(24)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 24, right: 24))
        }
    }

    private func makePreviewImage(systemName: String, backgroundColor: UIColor) -> UIImage? {
        let size = CGSize(width: 180, height: 132)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let rect = CGRect(origin: .zero, size: size)
            let colors = [
                backgroundColor.withAlphaComponent(0.15).cgColor,
                UIColor.black.withAlphaComponent(0.08).cgColor
            ] as CFArray

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            guard let iconImage = UIImage(
                systemName: systemName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 42, weight: .medium)
            )?.withTintColor(.white.withAlphaComponent(0.88), renderingMode: .alwaysOriginal) else {
                return
            }

            let imageRect = CGRect(
                x: rect.midX - 21,
                y: rect.midY - 21,
                width: 42,
                height: 42
            )
            iconImage.draw(in: imageRect)
        }
    }
}
