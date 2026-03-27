//
//  Untitled.swift
//  NSG
//
//  Created by hawon on 3/16/26.
//
import UIKit
import SnapKit
import Then

final class ShareViewController: UIViewController {

    private var selectedCategory: String?
    private let categories = ["장소", "기숙사", "대마고", "기타"]

    private let popularPosts = [
        SharePost(category: "기숙사", title: "화장실 변기가 막혔...", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다~~~ 변기를 잘 뚫는 법 ~!! 깨알호..."),
        SharePost(category: "기숙사", title: "화장실 변기가 막혔...", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다~~~ 변기를 잘 뚫는 법 ~!! 깨알호..."),
        SharePost(category: "장소", title: "화장실 변기가 막혔...", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다~~~ 변기를 잘 뚫는 법 ~!! 깨알호...")
    ]

    private let latestPosts = [
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다~~~ 변기를 잘 뚫는 법 ~!! 깨알호..."),
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다~~~ 변기를 잘 뚫는 법 ~!! 깨알호..."),
        SharePost(category: "기숙사", title: "화장실 변기가 막혔다고요??? 당장 들어오세요", content: "화장실 변기가 너무 자주 막히시죠?? 그래서 제가 오늘 끓여왔습니다~~~ 변기를 잘 뚫는 법 ~!! 깨알호...")
    ]

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
        $0.text = "정지윤"
        $0.font = .style(.body2)
        $0.textColor = .black800
    }

    private let classLabel = UILabel().then {
        $0.text = "10기"
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

    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillProportionally
    }

    private let popularScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }

    private let popularStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .fill
    }

    private let latestStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
    }

    private var categoryButtons: [CategoryChipButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configureUI()
        bindContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
            categoryStackView,
            popularTitleLabel,
            popularMoreLabel,
            popularScrollView,
            latestTitleLabel,
            latestMoreLabel,
            latestStackView
        ].forEach { contentView.addSubview($0) }

        popularScrollView.addSubview(popularStackView)
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

        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(screenTitleLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(24)
        }

        popularTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
        }

        popularMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(popularTitleLabel)
        }

        popularScrollView.snp.makeConstraints {
            $0.top.equalTo(popularTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }

        popularStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24))
            $0.height.equalToSuperview()
        }

        latestTitleLabel.snp.makeConstraints {
            $0.top.equalTo(popularScrollView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
        }

        latestMoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(latestTitleLabel)
        }

        latestStackView.snp.makeConstraints {
            $0.top.equalTo(latestTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    private func configureUI() {
        view.backgroundColor = .background
    }

    private func bindContent() {
        categoryButtons = categories.map { category in
            let button = CategoryChipButton(title: category)
            button.addTarget(self, action: #selector(didTapCategoryButton(_:)), for: .touchUpInside)
            return button
        }

        categoryButtons.forEach { categoryStackView.addArrangedSubview($0) }

        popularPosts
            .map { PopularPostCardView(post: $0) }
            .forEach { popularStackView.addArrangedSubview($0) }

        latestPosts
            .map { LatestPostCardView(post: $0) }
            .forEach { latestStackView.addArrangedSubview($0) }
    }

    @objc
    private func didTapCategoryButton(_ sender: CategoryChipButton) {
        let tappedTitle = sender.chipTitle
        selectedCategory = selectedCategory == tappedTitle ? nil : tappedTitle

        categoryButtons.forEach { button in
            button.isSelected = button.chipTitle == selectedCategory
        }
    }
}
