//
//  DetailViewController.swift
//  NSG
//
//  Created by hawon on 4/10/26.
//
import UIKit
import SnapKit
import Then

@MainActor
final class DetailViewController: UIViewController {

    private struct DetailComment {
        let id: String
        let author: String
        let message: String
        let isReply: Bool
    }

    private var post: SharePost
    private let commentService: CommentServicing
    private let tipService: TipServicing
    private var commentInputBottomConstraint: Constraint?
    private var replyTargetComment: DetailComment?
    private let defaultCommentPlaceholder = "댓글을 작성하세요."
    private var comments: [DetailComment] = []

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

    private let commentsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 16
    }

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

    init(
        post: SharePost,
        commentService: CommentServicing,
        tipService: TipServicing
    ) {
        self.post = post
        self.commentService = commentService
        self.tipService = tipService
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    convenience init(post: SharePost) {
        self.init(
            post: post,
            commentService: CommentService.shared,
            tipService: TipService.shared
        )
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
        fetchTipDetailIfNeeded()
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
            commentsStackView
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

        commentsStackView.snp.makeConstraints {
            $0.top.equalTo(reactionStackView.snp.bottom).offset(28)
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
        nameLabel.text = post.author ?? "익명"
        titleLabel.text = post.title
        contentLabel.text = post.content
        heartReactionView.configure(count: post.likeCount, isActivated: post.isLiked ?? false)
        commentReactionView.configure(count: post.commentCount)

        if let imageURL = post.imageURLs.first, !imageURL.isEmpty {
            contentImageView.isHidden = false
        } else {
            contentImageView.isHidden = !post.hasImages
        }

        if reactionStackView.arrangedSubviews.isEmpty {
            [heartReactionView, commentReactionView].forEach { reactionStackView.addArrangedSubview($0) }
        }
        commentTextField.placeholder = defaultCommentPlaceholder
        renderComments()
    }

    private func fetchTipDetailIfNeeded() {
        guard let postID = post.id else { return }

        Task { [weak self] in
            guard let self else { return }

            do {
                let detailedPost = try await tipService.tipDetail(id: postID)
                await MainActor.run {
                    self.post = detailedPost
                    self.configureContent()
                }
            } catch {
                await MainActor.run {
                    self.showPostLoadFailedAlert(error)
                }
            }
        }
    }

    private func startReply(to comment: DetailComment) {
        replyTargetComment = comment
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

        let popupTitle = replyTargetComment == nil ? "댓글 작성" : "대댓글 작성"
        let popupMessage = replyTargetComment == nil
            ? "댓글 작성 시 익명으로 작성이 가능합니다.\n익명으로 작성 하시겠습니까?\n아니오 클릭 시 실명과 기수가 보여집니다."
            : "대댓글 작성 시 익명으로 작성이 가능합니다.\n익명으로 작성 하시겠습니까?\n아니오 클릭 시 실명과 기수가 보여집니다."

        let popupView = NSGPopupView(
            title: popupTitle,
            message: popupMessage,
            cancelButtonTitle: "실명공개",
            confirmButtonTitle: "익명작성",
            cancelAction: { [weak self] in
                self?.submitComment(commentText, isAnonymous: false)
            },
            confirmAction: { [weak self] in
                self?.submitComment(commentText, isAnonymous: true)
            }
        )
        popupView.show(in: view)
    }

    private func submitComment(_ content: String, isAnonymous: Bool) {
        guard let postID = post.id, !postID.isEmpty else {
            showCommentUploadFailedAlert(CommentServiceError.invalidResponse)
            return
        }

        view.endEditing(true)

        Task {
            do {
                let response: CreateCommentResponse
                if let parentComment = replyTargetComment {
                    response = try await commentService.createReply(
                        postID: postID,
                        commentID: parentComment.id,
                        request: CreateCommentRequest(
                            content: content,
                            isAnonymous: isAnonymous
                        )
                    )
                    appendComment(response: response, isReply: true)
                } else {
                    response = try await commentService.createComment(
                        postID: postID,
                        request: CreateCommentRequest(
                            content: content,
                            isAnonymous: isAnonymous
                        )
                    )
                    appendComment(response: response, isReply: false)
                    commentReactionView.incrementCount()
                }
                resetReplyState()
            } catch {
                await MainActor.run {
                    showCommentUploadFailedAlert(error)
                }
            }
        }
    }

    private func appendComment(response: CreateCommentResponse, isReply: Bool) {
        let newComment = DetailComment(
            id: response.id,
            author: response.author,
            message: response.content,
            isReply: isReply
        )
        comments.append(newComment)
        renderComments()
    }

    private func renderComments() {
        commentsStackView.arrangedSubviews.forEach { subview in
            commentsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        comments.forEach { comment in
            let rowView = CommentRowView(
                author: comment.author,
                message: comment.message,
                showsMoreButton: !comment.isReply,
                isReply: comment.isReply
            )

            if !comment.isReply {
                rowView.onTapReplyAction = { [weak self] in
                    self?.startReply(to: comment)
                }
            }

            commentsStackView.addArrangedSubview(rowView)
        }
    }

    private func showCommentUploadFailedAlert(_ error: Error) {
        let message: String
        if case CommentServiceError.invalidBaseURL = error {
            message = "서버 주소(NSG_API_BASE_URL)가 설정되지 않아 댓글 동기화에 실패했어요."
        } else if case CommentServiceError.missingToken = error {
            AuthTokenStore.shared.clear()
            AppRootNavigator.moveToOnboarding()
            return
        } else if case CommentServiceError.server(let statusCode) = error, statusCode == 401 {
            AuthTokenStore.shared.clear()
            AppRootNavigator.moveToOnboarding()
            return
        } else {
            message = "서버 전송에 실패했어요. 네트워크 상태를 확인해주세요."
        }

        let alert = UIAlertController(title: "댓글 전송 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showPostLoadFailedAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "게시글 불러오기 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func resetReplyState() {
        replyTargetComment = nil
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

    var onTapReplyAction: (() -> Void)?

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
        onTapReplyAction?()
    }
}
