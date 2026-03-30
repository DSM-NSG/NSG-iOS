//
//  SearchViewController.swift
//  NSG
//
//  Created by hawon on 3/30/26.
//
import UIKit
import SnapKit
import Then

final class SearchViewController: UIViewController {

    private let categories = ["장소", "기숙사", "대마고", "기타"]
    private let allPosts = [
        SharePost(category: "장소", title: "학교에서 몰래 탈출하는 법", content: "학교 정문 말고도 빠르게 나갈 수 있는 타이밍을 정리해봤어요."),
        SharePost(category: "기숙사", title: "학교 기숙사에서 몰래 배달 시켜먹는 방법", content: "기숙사에서 눈치 안 보고 배달 받는 루트를 공유합니다."),
        SharePost(category: "기타", title: "학교 폭파시키기", content: "물론 진짜는 아니고 발표를 완전 터뜨리는 방법입니다."),
        SharePost(category: "대마고", title: "주말인데 학교 가야하나요?", content: "주말 자습과 귀가 기준을 정리해봤어요."),
        SharePost(category: "장소", title: "학교 와이파이 잘 터지는 곳 정리", content: "시험 기간에 안정적으로 인터넷 되는 장소를 정리했습니다."),
        SharePost(category: "기숙사", title: "기숙사 점호 전에 편의점 다녀오는 루트", content: "시간 안에 복귀 가능한 동선을 기준으로 정리했어요."),
        SharePost(category: "대마고", title: "학교 발표 수업 안 떨고 하는 법", content: "발표 전에 준비하면 좋은 포인트를 적어봤습니다."),
        SharePost(category: "기타", title: "학교에서 잠 깨는 제일 확실한 방법", content: "아침 수업 전에 잠을 깨는 루틴을 공유합니다.")
    ]

    private let searchInputView = SearchInputView()
    private let autoCompleteView = SearchAutoCompleteView()

    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillProportionally
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

    private var categoryButtons: [CategoryChipButton] = []
    private var selectedCategory: String?
    private var filteredResults: [String] = []
    private var filteredPosts: [SharePost] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
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
        bindContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(autoCompleteView)
    }

    private func addView() {
        [
            searchInputView,
            autoCompleteView,
            categoryStackView,
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

        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
        }

        resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
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
    }

    private func bindContent() {
        filteredPosts = allPosts
        categoryButtons = categories.map { category in
            let button = CategoryChipButton(title: category)
            button.addTarget(self, action: #selector(didTapCategoryButton(_:)), for: .touchUpInside)
            return button
        }

        categoryButtons.forEach { categoryStackView.addArrangedSubview($0) }
        resultCollectionView.reloadData()
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
        applyPostFiltering(with: keyword)

        if filteredResults.isEmpty {
            hideAutoComplete()
            return
        }

        autoCompleteView.update(results: filteredResults, keyword: keyword)
        updateAutoCompleteVisibility()
    }

    @objc
    private func didTapCategoryButton(_ sender: CategoryChipButton) {
        selectedCategory = selectedCategory == sender.chipTitle ? nil : sender.chipTitle

        categoryButtons.forEach { button in
            button.isSelected = button.chipTitle == selectedCategory
        }

        applyPostFiltering(with: searchInputView.currentText.trimmingCharacters(in: .whitespacesAndNewlines))
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
        applyPostFiltering(with: text)
        searchInputView.endEditing(true)
        hideAutoComplete()
    }

    private func applyPostFiltering(with keyword: String) {
        filteredPosts = allPosts.filter { post in
            let matchesKeyword = keyword.isEmpty
                || post.title.contains(keyword)
                || post.content.contains(keyword)
            let matchesCategory = selectedCategory == nil || post.category == selectedCategory
            return matchesKeyword && matchesCategory
        }

        resultCollectionView.reloadData()
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
}
