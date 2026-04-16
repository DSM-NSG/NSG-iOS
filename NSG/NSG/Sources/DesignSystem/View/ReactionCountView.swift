//
//  ReactionCountView.swift
//  NSG
//
//  Created by Codex on 4/16/26.
//
import UIKit
import SnapKit
import Then

final class ReactionCountView: UIStackView {

    enum DisplayMode {
        case toggle(onImage: String, offImage: String)
        case fixed(image: String)
    }

    var onToggle: ((Bool, Int) -> Void)?

    private let mode: DisplayMode
    private let iconSize: CGFloat

    private var isActivated: Bool = false
    private var count: Int = 0

    private let iconButton = UIButton(type: .system).then {
        $0.tintColor = .orange300
        $0.imageView?.contentMode = .scaleAspectFit
    }

    private let countLabel = UILabel().then {
        $0.textColor = .orange300
    }

    init(
        mode: DisplayMode,
        count: Int,
        isActivated: Bool = false,
        fontStyle: FontStyle = .body4,
        iconSize: CGFloat = 15,
        spacing: CGFloat = 3
    ) {
        self.mode = mode
        self.iconSize = iconSize
        self.count = max(0, count)
        self.isActivated = isActivated

        super.init(frame: .zero)

        axis = .horizontal
        alignment = .center
        self.spacing = spacing

        addArrangedSubview(iconButton)
        addArrangedSubview(countLabel)

        countLabel.font = .style(fontStyle)

        iconButton.snp.makeConstraints {
            $0.size.equalTo(iconSize)
        }

        iconButton.addTarget(self, action: #selector(didTapIcon), for: .touchUpInside)

        applyCurrentState()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(count: Int, isActivated: Bool? = nil) {
        self.count = max(0, count)
        if let isActivated {
            self.isActivated = isActivated
        }
        applyCurrentState()
    }

    func incrementCount() {
        count += 1
        updateCountLabel()
    }

    func decrementCount() {
        count = max(0, count - 1)
        updateCountLabel()
    }

    func toggleActivation() {
        switch mode {
        case .fixed:
            return
        case .toggle:
            setActivation(!isActivated, adjustCount: true)
        }
    }

    func setActivation(_ activated: Bool, adjustCount: Bool = false) {
        guard case .toggle = mode else { return }

        if adjustCount {
            if activated && !isActivated {
                incrementCount()
            } else if !activated && isActivated {
                decrementCount()
            }
        }

        isActivated = activated
        updateIcon()
        onToggle?(isActivated, count)
    }

    @objc
    private func didTapIcon() {
        toggleActivation()
    }

    private func applyCurrentState() {
        updateIcon()
        updateCountLabel()
        iconButton.isUserInteractionEnabled = {
            if case .toggle = mode { return true }
            return false
        }()
    }

    private func updateIcon() {
        let imageName: String

        switch mode {
        case let .fixed(image):
            imageName = image
        case let .toggle(onImage, offImage):
            imageName = isActivated ? onImage : offImage
        }

        iconButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    private func updateCountLabel() {
        countLabel.text = formattedCount(count)
    }

    private func formattedCount(_ value: Int) -> String {
        value >= 100 ? "99+" : String(value)
    }
}
