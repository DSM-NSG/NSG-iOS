//
//  SearchViewController.swift
//  NSG
//
//  Created by hawon on 3/30/26.
//
import UIKit
import SnapKit
import Then

@MainActor
final class SearchViewController: UIViewController {

    private let tipService: TipServicing

    private let searchInputView = SearchInputView()
    private let autoCompleteView = SearchAutoCompleteView()
    private let categoryFilterView = CategoryFilterView()
    private let emptyStateLabel = UILabel().then {
        $0.text = "검색 결과가 없어요."
        $0.font = .style(.body2)
        $0.textColor = .black500
        $0.textAlignment = .center
        $0.isHidden = true
    }

    private let resultCollectionView = UICollectionView(
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
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
        $0.keyboardDismissMode = .onDrag
    }

    private var selectedCategory: String?
    private var filteredResults: [String] = []
    private var allPosts: [SharePost] = []
    private var filteredPosts: [SharePost] = []
    private var searchTask: Task<Void, Never>?

    init(tipService: TipServicing) {
        self.tipService = tipService
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    convenience init() {
        self.init(tipService: TipService.shared)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "검색"
        view.backgroundColor = .background

        addView()
        setLayout()
        configureUI()
        fetchPosts(keyword: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(autoCompleteView)
    }

    private func addView() {
        [
            searchInputView,
            autoCompleteView,
            categoryFilterView,
            emptyStateLabel,
            resultCollectionView
        ].forEach { view.addSubview($0) }
    }

    private func setLayout() {
        searchInputView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }

        autoCompleteView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(150)
        }

        categoryFilterView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
        }

        resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryFilterView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }

        emptyStateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(categoryFilterView.snp.bottom).offset(48)
        }
    }

    private func configureUI() {
        navigationItem.largeTitleDisplayMode = .never
        autoCompleteView.layer.zPosition = 999
        view.bringSubviewToFront(autoCompleteView)
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        resultCollectionView.register(LatestPostCell.self, forCellWithReuseIdentifier: LatestPostCell.identifier)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        autoCompleteView.onSelectItem = { [weak self] text in
            self?.applyAutoComplete(text: text)
        }
        searchInputView.onBeginEditing = { [weak self] in
            self?.didBeginEditingSearchField()
        }
        searchInputView.onEndEditing = { [weak self] in
            self?.didEndEditingSearchField()
        }
        searchInputView.onTextChanged = { [weak self] text in
            self?.didChangeSearchTextField(text: text)
        }

        categoryFilterView.onSelectCategory = { [weak self] category in
            self?.selectedCategory = category
            let keyword = self?.searchInputView.currentText.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.fetchPosts(keyword: keyword)
        }
    }

    private func didBeginEditingSearchField() {
        searchInputView.setFocused(true)
        updateAutoCompleteVisibility()
    }

    private func didEndEditingSearchField() {
        searchInputView.setFocused(false)
        hideAutoComplete()
    }

    private func didChangeSearchTextField(text: String) {
        let keyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
        filteredResults = makeAutoCompleteResults(with: keyword)

        if filteredResults.isEmpty {
            hideAutoComplete()
        } else {
            autoCompleteView.update(results: filteredResults, keyword: keyword)
            updateAutoCompleteVisibility()
        }

        fetchPosts(keyword: keyword)
    }

    @objc
    private func didTapBackground() {
        view.endEditing(true)
    }

    private func updateAutoCompleteVisibility() {
        let keyword = searchInputView.currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShow = searchInputView.isEditingText && !keyword.isEmpty && !filteredResults.isEmpty
        autoCompleteView.isHidden = !shouldShow
    }

    private func hideAutoComplete() {
        autoCompleteView.isHidden = true
    }

    private func applyAutoComplete(text: String) {
        searchInputView.setText(text)
        filteredResults = makeAutoCompleteResults(with: text)
        fetchPosts(keyword: text)
        searchInputView.endEditing(true)
        hideAutoComplete()
    }

    private func fetchPosts(keyword: String?) {
        searchTask?.cancel()

        let trimmedKeyword = keyword?.trimmingCharacters(in: .whitespacesAndNewlines)
        let query = (trimmedKeyword?.isEmpty == false) ? trimmedKeyword : nil

        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                let posts = try await tipService.listTips(
                    category: selectedCategory,
                    page: 1,
                    search: query
                )

                guard !Task.isCancelled else { return }
                self.allPosts = posts
                self.filteredPosts = posts
                self.updateAutoCompleteSource(keyword: query)
                self.updateEmptyState()
                self.resultCollectionView.reloadData()
            } catch {
                guard !Task.isCancelled else { return }
                self.filteredPosts = []
                self.updateEmptyState()
                self.resultCollectionView.reloadData()
                self.showSearchFailedAlert(error)
            }
        }
    }

    private func updateAutoCompleteSource(keyword: String?) {
        guard let keyword, !keyword.isEmpty else {
            filteredResults = []
            hideAutoComplete()
            return
        }

        filteredResults = makeAutoCompleteResults(with: keyword)
        if filteredResults.isEmpty {
            hideAutoComplete()
        } else {
            autoCompleteView.update(results: filteredResults, keyword: keyword)
            updateAutoCompleteVisibility()
        }
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !filteredPosts.isEmpty
    }

    private func makeAutoCompleteResults(with keyword: String) -> [String] {
        guard !keyword.isEmpty else { return [] }

        var seenTitles = Set<String>()

        return allPosts.compactMap { post in
            guard post.title.contains(keyword) else { return nil }
            let isInserted = seenTitles.insert(post.title).inserted
            return isInserted ? post.title : nil
        }
    }

    private func showSearchFailedAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "검색 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LatestPostCell.identifier,
            for: indexPath
        ) as? LatestPostCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: filteredPosts[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost = filteredPosts[indexPath.item]
        let detailViewController = DetailViewController(post: selectedPost)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
