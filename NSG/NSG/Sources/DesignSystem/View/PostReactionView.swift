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

    var onHeartToggle: ((Bool, Int) -> Void)? {
        didSet {
            heartReactionView.onToggle = onHeartToggle
        }
    }

    private let heartReactionView = ReactionCountView(
        mode: .toggle(onImage: "heart", offImage: "heartOff"),
        count: 15,
        isActivated: false
    )

    private let commentReactionView = ReactionCountView(
        mode: .fixed(image: "coment"),
        count: 15
    )

    init() {
        super.init(frame: .zero)

        axis = .horizontal
        alignment = .center
        spacing = 6

        addArrangedSubview(heartReactionView)
        addArrangedSubview(commentReactionView)
        heartReactionView.onToggle = onHeartToggle
    }

    func configure(heartCount: Int, commentCount: Int, isHearted: Bool) {
        heartReactionView.configure(count: heartCount, isActivated: isHearted)
        commentReactionView.configure(count: commentCount)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
