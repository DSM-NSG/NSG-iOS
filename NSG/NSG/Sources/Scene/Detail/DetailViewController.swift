//
//  DetailViewController.swift
//  NSG
//
//  Created by hawon on 4/10/26.
//
import UIKit
import SnapKit
import Then

final class DetailViewController: UIViewController {

    private let post: SharePost
    private var commentInputBottomConstraint: Constraint?

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }

    private let contentView = UIView()

    private let profileImageView = UIView().then {
        $0.backgroundColor = .orange400
        $0.layer.cornerRadius = 25
    }

    private let nameLabel = UILabel().then {
        $0.text = "익명2"
        $0.font = .style(.body2)
        $0.textColor = .black800
    }

    private let titleLabel = UILabel().then {
        $0.font = .style(.header1)
        $0.textColor = .black800
        $0.numberOfLines = 0
    }

    private let contentLabel = UILabel().then {
        $0.font = .style(.body1)
        $0.textColor = .black700
        $0.numberOfLines = 0
    }

    private let contentImageView = UIImageView().then {
        $0.image = UIImage(named: "school")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .black50
    }

    private let reactionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
    }

    private let firstCommentView = CommentRowView(
        author: "정지윤 10기",
        message: "정말 좋아요 저도 동참할래요",
        showsMoreButton: true,
        isReply: false
    )

    private let secondCommentView = CommentRowView(
        author: "익명1",
        message: "와 이런 생각을??",
        showsMoreButton: true,
        isReply: false
    )

    private let moreReplyButton = UIButton(type: .system).then {
        $0.setTitle("더댓글 읽기", for: .normal)
        $0.titleLabel?.font = .style(.body4)
        $0.setTitleColor(.orange300, for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.orange300.cgColor
        $0.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }

    private let replyCommentView = CommentRowView(
        author: "익명1",
        message: "와 이런 생각을??",
        showsMoreButton: false,
        isReply: true
    )

    private let commentInputBackground = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
    }

    private let commentTextField = UITextField().then {
        $0.placeholder = "댓글을 작성하세요."
        $0.font = .style(.body2)
        $0.textColor = .black800
        $0.borderStyle = .none
    }

    private let sendButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .orange400
    }

    init(post: SharePost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addView()
        setLayout()
        configureContent()
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        enableKeyboardDismissOnTap()
        if let commentInputBottomConstraint {
            bindKeyboard(to: commentInputBottomConstraint, defaultInset: 10)
        }
    }

    private func setupNavigationBar() {
        view.backgroundColor = .background
        navigationItem.title = ""
        navigationItem.hidesBackButton = true

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = .black800
        navigationItem.leftBarButtonItem = backButton
    }

    private func addView() {
        view.addSubview(scrollView)
        view.addSubview(commentInputBackground)
        scrollView.addSubview(contentView)

        [
            profileImageView,
            nameLabel,
            titleLabel,
            contentLabel,
            contentImageView,
            reactionStackView,
            firstCommentView,
            secondCommentView,
            moreReplyButton,
            replyCommentView
        ].forEach { contentView.addSubview($0) }

        [
            commentTextField,
            sendButton
        ].forEach { commentInputBackground.addSubview($0) }
    }

    private func setLayout() {
        commentInputBackground.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            commentInputBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10).constraint
            $0.height.equalTo(52)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(commentInputBackground.snp.top).offset(-12)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(50)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalTo(profileImageView)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        contentImageView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.lessThanOrEqualTo(220)
            $0.height.equalTo(contentImageView.snp.width).multipliedBy(0.6)
        }

        reactionStackView.snp.makeConstraints {
            $0.top.equalTo(contentImageView.snp.bottom).offset(14)
            $0.trailing.equalToSuperview().inset(24)
        }

        firstCommentView.snp.makeConstraints {
            $0.top.equalTo(reactionStackView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        secondCommentView.snp.makeConstraints {
            $0.top.equalTo(firstCommentView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        moreReplyButton.snp.makeConstraints {
            $0.top.equalTo(secondCommentView.snp.top).offset(8)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(24)
        }

        replyCommentView.snp.makeConstraints {
            $0.top.equalTo(secondCommentView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }

        commentTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
        }
    }

    private func configureContent() {
        titleLabel.text = post.title
        contentLabel.text = post.content

        let heartReaction = makeReactionItem(symbolName: "heart", count: "99+")
        let commentReaction = makeReactionItem(symbolName: "coment", count: "99+")
        [heartReaction, commentReaction].forEach { reactionStackView.addArrangedSubview($0) }
    }

    private func makeReactionItem(symbolName: String, count: String) -> UIStackView {
        let icon = UIImageView().then {
            $0.image = UIImage(named: symbolName)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = .orange300
            $0.contentMode = .scaleAspectFit
        }

        let label = UILabel().then {
            $0.text = count
            $0.font = .style(.body3)
            $0.textColor = .orange300
        }

        icon.snp.makeConstraints {
            $0.size.equalTo(16)
        }

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }

    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func didTapSendButton() {
        guard let commentText = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !commentText.isEmpty else {
            return
        }

        let popupView = NSGPopupView(
            title: "댓글 작성",
            message: "댓글 작성 시 익명으로 작성이 가능합니다.\n익명으로 작성 하시겠습니까?\n아니오 클릭 시 실명과 기수가 보여집니다.",
            cancelButtonTitle: "실명공개",
            confirmButtonTitle: "익명작성",
            cancelAction: { [weak self] in
                self?.view.endEditing(true)
                // TODO: 실명 댓글 작성 API 연결
            },
            confirmAction: { [weak self] in
                self?.view.endEditing(true)
                // TODO: 익명 댓글 작성 API 연결
            }
        )
        popupView.show(in: view)
    }
}

private final class CommentRowView: UIView {

    private let iconImageView = UIImageView().then {
        $0.backgroundColor = .orange400
        $0.layer.cornerRadius = 16
    }

    private let authorLabel = UILabel().then {
        $0.font = .style(.header3)
        $0.textColor = .black800
    }

    private let messageLabel = UILabel().then {
        $0.font = .style(.body1)
        $0.textColor = .black700
        $0.numberOfLines = 0
    }

    private let moreButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .orange400
    }

    private let replyArrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "arrow.turn.down.right")
        $0.tintColor = .orange400
    }

    init(author: String, message: String, showsMoreButton: Bool, isReply: Bool) {
        super.init(frame: .zero)

        authorLabel.text = author
        messageLabel.text = message

        if isReply {
            addSubview(replyArrowImageView)
            replyArrowImageView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.top.equalToSuperview().offset(7)
                $0.size.equalTo(16)
            }
        }

        [iconImageView, authorLabel, messageLabel].forEach { addSubview($0) }
        if showsMoreButton {
            addSubview(moreButton)
        }

        let leadingInset = isReply ? 24 : 0

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(leadingInset)
            $0.size.equalTo(32)
        }

        authorLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.centerY.equalTo(iconImageView)
        }

        if showsMoreButton {
            moreButton.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.centerY.equalTo(authorLabel)
                $0.size.equalTo(16)
            }
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.equalTo(authorLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
