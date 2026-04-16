//
//  MajorViewController.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import SnapKit
import Then

final class MajorViewController: UIViewController {

    private enum Mode {
        case home
        case searchResult
    }

    private let popularPosts = [
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift..."),
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift..."),
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift..."),
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift..."),
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift...")
    ]

    private let latestPosts = [
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다니..."),
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다니..."),
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다니..."),
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다니..."),
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift..."),
        SharePost(category: "기숙사", title: "Swift", content: "Swift Swift Swift Swift Swift Swift Swift Swift Swift Swift...")
    ]

    private let trendingTopics = [
        "FE", "Flutter", "iOS", "Design", "BE",
        "GO", "HOME", "tired", "why", "bomb"
    ]

    private var mode: Mode = .home
    private var filteredPopularPosts: [SharePost] = []
    private var filteredLatestPosts: [SharePost] = []

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }

    private let contentView = UIView()

    private let searchContainerView = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
    }

    private let searchTextField = UITextField().then {
        $0.font = .style(.body3)
        $0.textColor = .black800
        $0.tintColor = .orange500
        $0.returnKeyType = .search
        $0.attributedPlaceholder = NSAttributedString(
            string: "찾고싶은 검색어를 입력해주세요.",
            attributes: [.foregroundColor: UIColor.black400]
        )
    }

    private let autoCompleteView = SearchAutoCompleteView()

    private let boardTitleLabel = UILabel().then {
        $0.text = "전공 마당"
        $0.font = .style(.header1)
        $0.textColor = .black800
    }

    private let trendTitleLabel = UILabel().then {
        $0.text = "현재 트렌드 토픽"
        $0.font = .style(.header2)
        $0.textColor = .black800
    }

    private let trendCardView = UIView().then {
        $0.backgroundColor = .black50
        $0.layer.cornerRadius = 8
    }

    private let trendLeftStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    private let trendRightStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    private let popularTitleLabel = UILabel().then {
        $0.text = "인기글"
        $0.font = .style(.header1)
        $0.textColor = .black800
    }

    private let latestTitleLabel = UILabel().then {
        $0.text = "최신글"
        $0.font = .style(.header1)
        $0.textColor = .black800
    }

    private let popularMoreLabel = UILabel().then {
        $0.text = "더보기"
        $0.font = .style(.body3)
        $0.textColor = .black800
    }

    private let latestMoreLabel = UILabel().then {
        $0.text = "더보기"
        $0.font = .style(.body3)
        $0.textColor = .black800
    }

    private let popularCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.itemSize = CGSize(width: 144, height: 140)
            return layout
        }()
    ).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }

    private let latestCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
            return layout
        }()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }

    private var latestTopFromTrendConstraint: Constraint?
    private var latestTopFromPopularConstraint: Constraint?
    private var latestCollectionHeightConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configureUI()
        bindContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        latestCollectionHeightConstraint?.update(
            offset: latestCollectionView.collectionViewLayout.collectionViewContentSize.height
        )
        view.bringSubviewToFront(autoCompleteView)
    }

    private func addView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            searchContainerView,
            boardTitleLabel,
            trendTitleLabel,
            trendCardView,
            popularTitleLabel,
            popularMoreLabel,
            popularCollectionView,
            latestTitleLabel,
            latestMoreLabel,
            latestCollectionView
        ].forEach { contentView.addSubview($0) }

        searchContainerView.addSubview(searchTextField)
        view.addSubview(autoCompleteView)

        let trendColumns = UIStackView(arrangedSubviews: [trendLeftStack, trendRightStack])
        trendColumns.axis = .horizontal
        trendColumns.alignment = .fill
        trendColumns.distribution = .fillEqually
        trendColumns.spacing = 22

        trendCardView.addSubview(trendColumns)
        trendColumns.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18))
        }

        bindTrendTopics()
    }

    private func setLayout() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        searchContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }

        searchTextField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }

        autoCompleteView.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(170)
        }

        boardTitleLabel.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
        }

        trendTitleLabel.snp.makeConstraints {
            $0.top.equalTo(boardTitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }

        trendCardView.snp.makeConstraints {
            $0.top.equalTo(trendTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        popularTitleLabel.snp.makeConstraints {
            $0.top.equalTo(searchContainerView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
        }

        popularMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(popularTitleLabel)
        }

        popularCollectionView.snp.makeConstraints {
            $0.top.equalTo(popularTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }

        latestTitleLabel.snp.makeConstraints {
            latestTopFromTrendConstraint = $0.top.equalTo(trendCardView.snp.bottom).offset(20).constraint
            latestTopFromPopularConstraint = $0.top.equalTo(popularCollectionView.snp.bottom).offset(24).constraint
            $0.leading.equalToSuperview().offset(24)
        }

        latestMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(latestTitleLabel)
        }

        latestCollectionView.snp.makeConstraints {
            $0.top.equalTo(latestTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            latestCollectionHeightConstraint = $0.height.equalTo(0).constraint
        }
    }

    private func configureUI() {
        view.backgroundColor = .background
        navigationItem.largeTitleDisplayMode = .never

        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(didChangeSearchTextField), for: .editingChanged)

        popularMoreLabel.isUserInteractionEnabled = true
        latestMoreLabel.isUserInteractionEnabled = true
        popularMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPopularMoreLabel))
        )
        latestMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLatestMoreLabel))
        )

        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        popularCollectionView.register(PopularPostCell.self, forCellWithReuseIdentifier: PopularPostCell.identifier)

        latestCollectionView.delegate = self
        latestCollectionView.dataSource = self
        latestCollectionView.register(LatestPostCell.self, forCellWithReuseIdentifier: LatestPostCell.identifier)

        autoCompleteView.onSelectItem = { [weak self] text in
            self?.searchTextField.text = text
            self?.commitSearch(with: text)
            self?.searchTextField.resignFirstResponder()
            self?.hideAutoComplete()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func bindContent() {
        filteredPopularPosts = popularPosts
        filteredLatestPosts = latestPosts
        apply(mode: .home)
    }

    private func bindTrendTopics() {
        trendLeftStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        trendRightStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let leftItems = Array(trendingTopics.prefix(5))
        let rightItems = Array(trendingTopics.dropFirst(5).prefix(5))

        leftItems.enumerated().forEach { index, title in
            trendLeftStack.addArrangedSubview(makeTrendLabel(rank: index + 1, title: title))
        }
        rightItems.enumerated().forEach { index, title in
            trendRightStack.addArrangedSubview(makeTrendLabel(rank: index + 6, title: title))
        }
    }

    private func makeTrendLabel(rank: Int, title: String) -> UILabel {
        let textColor: UIColor = rank <= 3 ? .orange400 : .black800

        let attributed = NSMutableAttributedString(
            string: "\(rank). ",
            attributes: [
                .font: UIFont.style(.body1),
                .foregroundColor: textColor
            ]
        )

        attributed.append(
            NSAttributedString(
                string: title,
                attributes: [
                    .font: UIFont.style(.body1),
                    .foregroundColor: textColor
                ]
            )
        )

        return UILabel().then {
            $0.attributedText = attributed
            $0.numberOfLines = 1
        }
    }

    private func updateAutoComplete(with keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            hideAutoComplete()
            return
        }

        let results = makeAutoCompleteResults(with: trimmed)

        guard !results.isEmpty else {
            hideAutoComplete()
            return
        }

        autoCompleteView.update(results: results, keyword: trimmed)
        autoCompleteView.isHidden = false
    }

    private func makeAutoCompleteResults(with keyword: String) -> [String] {
        guard !keyword.isEmpty else { return [] }

        var seenTitles = Set<String>()
        let allPosts = popularPosts + latestPosts

        return allPosts.compactMap { post in
            guard post.title.localizedCaseInsensitiveContains(keyword) else { return nil }
            let inserted = seenTitles.insert(post.title).inserted
            return inserted ? post.title : nil
        }
    }

    private func commitSearch(with keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            filteredPopularPosts = popularPosts
            filteredLatestPosts = latestPosts
            apply(mode: .home)
            return
        }

        filteredPopularPosts = popularPosts.filter { post in
            post.title.localizedCaseInsensitiveContains(trimmed)
            || post.content.localizedCaseInsensitiveContains(trimmed)
        }
        filteredLatestPosts = latestPosts.filter { post in
            post.title.localizedCaseInsensitiveContains(trimmed)
            || post.content.localizedCaseInsensitiveContains(trimmed)
        }

        apply(mode: .searchResult)
    }

    private func apply(mode: Mode) {
        self.mode = mode

        let isHome = mode == .home

        boardTitleLabel.isHidden = !isHome
        trendTitleLabel.isHidden = !isHome
        trendCardView.isHidden = !isHome

        popularTitleLabel.isHidden = isHome
        popularMoreLabel.isHidden = isHome
        popularCollectionView.isHidden = isHome

        latestTopFromTrendConstraint?.isActive = isHome
        latestTopFromPopularConstraint?.isActive = !isHome

        popularCollectionView.reloadData()
        latestCollectionView.reloadData()

        view.layoutIfNeeded()
        latestCollectionHeightConstraint?.update(
            offset: latestCollectionView.collectionViewLayout.collectionViewContentSize.height
        )
    }

    private var activePopularPosts: [SharePost] {
        mode == .home ? popularPosts : filteredPopularPosts
    }

    private var activeLatestPosts: [SharePost] {
        mode == .home ? latestPosts : filteredLatestPosts
    }

    private func hideAutoComplete() {
        autoCompleteView.isHidden = true
    }

    @objc
    private func didTapBackground() {
        view.endEditing(true)
    }

    @objc
    private func didChangeSearchTextField() {
        updateAutoComplete(with: searchTextField.text ?? "")
    }

    @objc
    private func didTapPopularMoreLabel() {
        let viewController = MajorTotalPostViewController(title: "인기글", posts: activePopularPosts)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc
    private func didTapLatestMoreLabel() {
        let viewController = MajorTotalPostViewController(title: "최신글", posts: activeLatestPosts)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MajorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateAutoComplete(with: textField.text ?? "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        hideAutoComplete()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitSearch(with: textField.text ?? "")
        textField.resignFirstResponder()
        hideAutoComplete()
        return true
    }
}

extension MajorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == popularCollectionView {
            return activePopularPosts.count
        }
        return activeLatestPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == popularCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopularPostCell.identifier,
                for: indexPath
            ) as? PopularPostCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: activePopularPosts[indexPath.item])
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LatestPostCell.identifier,
            for: indexPath
        ) as? LatestPostCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: activeLatestPosts[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost: SharePost
        if collectionView == popularCollectionView {
            selectedPost = activePopularPosts[indexPath.item]
        } else {
            selectedPost = activeLatestPosts[indexPath.item]
        }

        let detailViewController = DetailViewController(post: selectedPost)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
