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
    private var replyTargetAuthor: String?
    private let defaultCommentPlaceholder = "댓글을 작성하세요."

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

    private let heartReactionView = ReactionCountView(
        mode: .toggle(onImage: "heart", offImage: "heartOff"),
        count: 99,
        isActivated: true,
        fontStyle: .body3,
        iconSize: 16,
        spacing: 2
    )

    private let commentReactionView = ReactionCountView(
        mode: .fixed(image: "coment"),
        count: 100,
        fontStyle: .body3,
        iconSize: 16,
        spacing: 2
    )

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
        $0.returnKeyType = .send
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
        bindCommentActions()
        commentTextField.delegate = self
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

        [heartReactionView, commentReactionView].forEach { reactionStackView.addArrangedSubview($0) }
        commentTextField.placeholder = defaultCommentPlaceholder
    }

    private func bindCommentActions() {
        firstCommentView.onTapReplyAction = { [weak self] author in
            self?.startReply(to: author)
        }

        secondCommentView.onTapReplyAction = { [weak self] author in
            self?.startReply(to: author)
        }
    }

    private func startReply(to author: String) {
        replyTargetAuthor = author
        commentTextField.placeholder = "대댓글을 작성하세요."
        commentTextField.becomeFirstResponder()
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

        let popupTitle = replyTargetAuthor == nil ? "댓글 작성" : "대댓글 작성"
        let popupMessage = replyTargetAuthor == nil
            ? "댓글 작성 시 익명으로 작성이 가능합니다.\n익명으로 작성 하시겠습니까?\n아니오 클릭 시 실명과 기수가 보여집니다."
            : "대댓글 작성 시 익명으로 작성이 가능합니다.\n익명으로 작성 하시겠습니까?\n아니오 클릭 시 실명과 기수가 보여집니다."

        let popupView = NSGPopupView(
            title: popupTitle,
            message: popupMessage,
            cancelButtonTitle: "실명공개",
            confirmButtonTitle: "익명작성",
            cancelAction: { [weak self] in
                self?.view.endEditing(true)
                self?.resetReplyState()
                // TODO: 실명 댓글 작성 API 연결
            },
            confirmAction: { [weak self] in
                self?.view.endEditing(true)
                self?.resetReplyState()
                // TODO: 익명 댓글 작성 API 연결
            }
        )
        popupView.show(in: view)
    }

    private func resetReplyState() {
        replyTargetAuthor = nil
        commentTextField.text = nil
        commentTextField.placeholder = defaultCommentPlaceholder
    }
}

extension DetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSendButton()
        return false
    }
}

private final class CommentRowView: UIView {

    var onTapReplyAction: ((String) -> Void)?

    private let author: String
    private var isReplyActionVisible = false
    private var replyActionHeightConstraint: Constraint?

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
        $0.setImage(UIImage(named: "more")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .orange400
    }

    private let replyActionButton = UIButton(type: .system).then {
        $0.setTitle("대댓글 달기", for: .normal)
        $0.titleLabel?.font = .style(.body4)
        $0.setTitleColor(.black700, for: .normal)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.orange400.cgColor
        $0.clipsToBounds = true
        $0.isHidden = true
    }

    private let replyArrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "arrow.turn.down.right")
        $0.tintColor = .orange400
    }

    init(author: String, message: String, showsMoreButton: Bool, isReply: Bool) {
        self.author = author
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
            addSubview(replyActionButton)
            configureMoreAction()
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

            replyActionButton.snp.makeConstraints {
                $0.top.equalTo(moreButton.snp.bottom).offset(12)
                $0.trailing.equalTo(moreButton.snp.trailing)
                $0.width.equalTo(58)
                replyActionHeightConstraint = $0.height.equalTo(0).constraint
            }
        }

        messageLabel.snp.makeConstraints {
            if showsMoreButton {
                $0.top.equalTo(replyActionButton.snp.bottom).offset(8)
            } else {
                $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            }
            $0.leading.equalTo(authorLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureMoreAction() {
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        replyActionButton.addTarget(self, action: #selector(didTapReplyActionButton), for: .touchUpInside)
    }

    @objc
    private func didTapMoreButton() {
        isReplyActionVisible.toggle()
        replyActionButton.isHidden = !isReplyActionVisible
        replyActionHeightConstraint?.update(offset: isReplyActionVisible ? 21 : 0)
    }

    @objc
    private func didTapReplyActionButton() {
        isReplyActionVisible = false
        replyActionButton.isHidden = true
        replyActionHeightConstraint?.update(offset: 0)
        onTapReplyAction?(author)
    }
}
