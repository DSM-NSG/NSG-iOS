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
    private let sampleResults = [
        "학교에서 몰래 탈출하는 법",
        "학교 기숙사에서 몰래 배달 시켜먹는 방법",
        "학교 폭파시키기",
        "주말인데 학교 가야하나요?"
    ]

    private let searchInputView = SearchInputView()
    private let autoCompleteView = SearchAutoCompleteView()

    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillProportionally
    }

    private var categoryButtons: [CategoryChipButton] = []
    private var filteredResults: [String] = []

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

    private func addView() {
        [
            searchInputView,
            autoCompleteView,
            categoryStackView,
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
    }

    private func configureUI() {
        navigationItem.largeTitleDisplayMode = .never
        view.bringSubviewToFront(autoCompleteView)

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
        categoryButtons = categories.map { category in
            let button = CategoryChipButton(title: category)
            button.addTarget(self, action: #selector(didTapCategoryButton(_:)), for: .touchUpInside)
            return button
        }

        categoryButtons.forEach { categoryStackView.addArrangedSubview($0) }
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
        filteredResults = keyword.isEmpty ? [] : sampleResults.filter { $0.contains(keyword) }

        if filteredResults.isEmpty {
            hideAutoComplete()
            return
        }

        autoCompleteView.update(results: filteredResults, keyword: keyword)
        updateAutoCompleteVisibility()
    }

    @objc
    private func didTapCategoryButton(_ sender: CategoryChipButton) {
        categoryButtons.forEach { button in
            button.isSelected = button === sender
        }
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
        searchInputView.endEditing(true)
        hideAutoComplete()
    }
}
