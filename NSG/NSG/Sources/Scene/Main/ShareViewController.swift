//
//  Untitled.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import SnapKit
import Then

@MainActor
final class ShareViewController: UIViewController {

    private var selectedCategory: String?
    private var popularPosts: [SharePost] = []
    private var latestPosts: [SharePost] = []
    private let tipService: TipServicing

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
        $0.text = "사용자"
        $0.font = .style(.body2)
        $0.textColor = .black800
    }

    private let classLabel = UILabel().then {
        $0.text = "-기"
        $0.font = .style(.body2)
        $0.textColor = .black800
    }

    private let screenTitleLabel = UILabel().then {
        $0.text = "꿀팁 공유"
        $0.font = .style(.header1)
        $0.textColor = .black800
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

    private let searchButton = UIButton(type: .system).then {
        let image = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.tintColor = .orange400
    }

    private let categoryFilterView = CategoryFilterView()

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

    private var latestCollectionHeightConstraint: Constraint?

    init(tipService: TipServicing) {
        self.tipService = tipService
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(tipService: TipService.shared)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configureUI()
        updateUserInfo()
        fetchTips()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        latestCollectionHeightConstraint?.update(offset: latestCollectionView.collectionViewLayout.collectionViewContentSize.height)
    }

    private func addView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            profileImageView,
            nameLabel,
            classLabel,
            screenTitleLabel,
            searchButton,
            categoryFilterView,
            popularTitleLabel,
            popularMoreLabel,
            popularCollectionView,
            latestTitleLabel,
            latestMoreLabel,
            latestCollectionView
        ].forEach { contentView.addSubview($0) }
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

        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(50)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalTo(profileImageView)
        }

        classLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(profileImageView)
        }

        screenTitleLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(24)
        }

        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(screenTitleLabel)
            $0.size.equalTo(24)
        }

        categoryFilterView.snp.makeConstraints {
            $0.top.equalTo(screenTitleLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(24)
        }

        popularTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryFilterView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
        }

        popularMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(popularTitleLabel)
        }

        popularCollectionView.snp.makeConstraints {
            $0.top.equalTo(popularTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }

        latestTitleLabel.snp.makeConstraints {
            $0.top.equalTo(popularCollectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
        }

        latestMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(latestTitleLabel)
        }

        latestCollectionView.snp.makeConstraints {
            $0.top.equalTo(latestTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            latestCollectionHeightConstraint = $0.height.equalTo(0).constraint
        }
    }

    private func configureUI() {
        view.backgroundColor = .background
        popularMoreLabel.isUserInteractionEnabled = true
        latestMoreLabel.isUserInteractionEnabled = true
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)

        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        popularCollectionView.register(PopularPostCell.self, forCellWithReuseIdentifier: PopularPostCell.identifier)

        latestCollectionView.delegate = self
        latestCollectionView.dataSource = self
        latestCollectionView.register(LatestPostCell.self, forCellWithReuseIdentifier: LatestPostCell.identifier)

        popularMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapPopularMoreLabel))
        )
        latestMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLatestMoreLabel))
        )

        categoryFilterView.onSelectCategory = { [weak self] category in
            self?.selectedCategory = category
            self?.fetchTips()
        }
    }

    private func updateUserInfo() {
        guard let user = AuthTokenStore.shared.currentUser else {
            return
        }

        nameLabel.text = user.name
        classLabel.text = "\(user.grade)기"
    }

    private func fetchTips() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let posts = try await tipService.listTips(category: selectedCategory, page: 1, search: nil)
                await MainActor.run {
                    self.latestPosts = posts
                    self.popularPosts = Array(posts.sorted(by: { $0.likeCount > $1.likeCount }).prefix(10))
                    self.bindContent()
                }
            } catch {
                await MainActor.run {
                    self.presentLoadError(error)
                }
            }
        }
    }

    private func bindContent() {
        popularCollectionView.reloadData()
        latestCollectionView.reloadData()
        latestCollectionView.layoutIfNeeded()
        latestCollectionHeightConstraint?.update(offset: latestCollectionView.collectionViewLayout.collectionViewContentSize.height)
    }

    private func presentLoadError(_ error: Error) {
        let alert = UIAlertController(
            title: "게시글 불러오기 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @objc
    private func didTapSearchButton() {
        let searchViewController = SearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    @objc
    private func didTapPopularMoreLabel() {
        let totalPostViewController = TotalPostViewController(title: "인기글", posts: popularPosts)
        navigationController?.pushViewController(totalPostViewController, animated: true)
    }

    @objc
    private func didTapLatestMoreLabel() {
        let totalPostViewController = TotalPostViewController(title: "최신글", posts: latestPosts)
        navigationController?.pushViewController(totalPostViewController, animated: true)
    }
}

extension ShareViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == popularCollectionView ? popularPosts.count : latestPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == popularCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopularPostCell.identifier,
                for: indexPath
            ) as? PopularPostCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: popularPosts[indexPath.item])
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LatestPostCell.identifier,
            for: indexPath
        ) as? LatestPostCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: latestPosts[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost: SharePost
        if collectionView == popularCollectionView {
            selectedPost = popularPosts[indexPath.item]
        } else {
            selectedPost = latestPosts[indexPath.item]
        }

        let detailViewController = DetailViewController(post: selectedPost)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
