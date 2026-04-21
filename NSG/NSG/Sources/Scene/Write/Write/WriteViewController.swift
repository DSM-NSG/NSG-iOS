//
//  WriteViewController.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit
import MapKit
import SnapKit
import Then

@MainActor
final class WriteViewController: UIViewController {

    private struct MajorChipItem: Equatable {
        let id: String
        let name: String
    }

    private enum WriteUploadError: LocalizedError {
        case invalidImageData
        case missingLocationPlace
        case invalidLocationCategory

        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "이미지 변환에 실패했어요."
            case .missingLocationPlace:
                return "장소를 검색해서 선택해주세요."
            case .invalidLocationCategory:
                return "장소 카테고리를 선택해주세요."
            }
        }
    }

    private struct PlaceSearchItem {
        let name: String
        let address: String
        let latitude: Double
        let longitude: Double
        let naverMapURL: String
    }

    private let tipType: TipType
    private let tipService: TipServicing
    private var selectedImages: [UIImage] = []
    private var selectedImageURLs: [String] = []
    private var placeSearchTask: Task<Void, Never>?
    private var placeResults: [PlaceSearchItem] = []
    private var isApplyingSelectedPlace = false
    private var selectedPlace: PlaceSearchItem? {
        didSet { updateShareButtonState() }
    }
    private var allMajors: [MajorCategory] = []
    private var filteredMajors: [MajorCategory] = []
    private var selectedMajors: [MajorChipItem] = [] {
        didSet {
            renderSelectedMajorChips()
            updateShareButtonState()
        }
    }
    private var shareButtonBottomConstraint: Constraint?
    private var majorDropdownHeightConstraint: Constraint?
    private var majorChipsHeightConstraint: Constraint?
    private var placeDropdownHeightConstraint: Constraint?
    private var selectedCategory: LocationCategory? {
        didSet { updateShareButtonState() }
    }

    private let titleTextField = NSGSingleTextField(placeholder: "제목")
    private let placeTextField = NSGSingleTextField(placeholder: "장소를 입력해주세요.")
    private let contentTextView = WriteTextView(placeholder: "내용", maxLength: 1000)

    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(LocationCategoryCell.self,
                    forCellWithReuseIdentifier: LocationCategoryCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let majorCategoryLabel = UILabel().then {
        $0.text = "카테고리 추가하기"
        $0.font = .style(.body4)
        $0.textColor = .black500
        $0.isHidden = true
    }

    private let majorTextFieldContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.orange300.cgColor
        $0.isHidden = true
    }

    private let majorTextField = UITextField().then {
        $0.font = .style(.body3)
        $0.textColor = .black800
        $0.tintColor = .orange500
        $0.attributedPlaceholder = NSAttributedString(
            string: "전공 카테고리를 검색해주세요.",
            attributes: [.foregroundColor: UIColor.black400]
        )
        $0.returnKeyType = .done
        $0.clearButtonMode = .whileEditing
    }

    private let majorChipsScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = true
        $0.isHidden = true
    }

    private let majorChipsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }

    private let majorDropdownTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.rowHeight = 40
        $0.isHidden = true
    }

    private let placeDropdownTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.rowHeight = 44
        $0.isHidden = true
    }
    
    private let imageScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = true
    }

    private let imageStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }

    private lazy var addImageButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor.black50
        $0.layer.cornerRadius = 8
        $0.tintColor = UIColor.black500
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.addTarget(self, action: #selector(didTapAddImage), for: .touchUpInside)
    }

    private lazy var shareButton = NSGButton(title: "공유", color: .orange500).then {
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }

    init(tipType: TipType, tipService: TipServicing) {
        self.tipType = tipType
        self.tipService = tipService
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    convenience init(tipType: TipType) {
        self.init(tipType: tipType, tipService: TipService.shared)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupLayout()
        setupObservers()
        if tipType == .location && selectedCategory == nil {
            selectedCategory = .cafe
            categoryCollectionView.reloadData()
        }
        if tipType == .major {
            bindMajorCategoryUI()
            fetchMajors()
        }
        enableKeyboardDismissOnTap()
        if let shareButtonBottomConstraint {
            bindKeyboard(to: shareButtonBottomConstraint, defaultInset: 19)
        }
    }

    private func setupNavigationBar() {
        title = tipType.navigationTitle
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.black800
        ]
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = UIColor.black800
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleTextField)
        if tipType == .location {
            view.addSubview(placeTextField)
            view.addSubview(placeDropdownTableView)
        }
        if tipType.requiresCategorySelection {
            view.addSubview(categoryCollectionView)
        }
        view.addSubview(contentTextView)
        if tipType.requiresMajorSelection {
            view.addSubview(majorCategoryLabel)
            view.addSubview(majorTextFieldContainer)
            view.addSubview(majorChipsScrollView)
            view.addSubview(majorDropdownTableView)
            majorTextFieldContainer.addSubview(majorTextField)
            majorChipsScrollView.addSubview(majorChipsStackView)
        }
        view.addSubview(imageScrollView)
        view.addSubview(shareButton)

        imageScrollView.addSubview(imageStackView)
        imageStackView.addArrangedSubview(addImageButton)
    }

    private func setupLayout() {
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.right.equalToSuperview().inset(23)
            $0.height.equalTo(52)
        }

        let contentTopAnchor: ConstraintItem
        if tipType == .location {
            placeTextField.snp.makeConstraints {
                $0.top.equalTo(titleTextField.snp.bottom).offset(12)
                $0.left.right.equalToSuperview().inset(23)
                $0.height.equalTo(52)
            }

            placeDropdownTableView.snp.makeConstraints {
                $0.top.equalTo(placeTextField.snp.bottom).offset(6)
                $0.left.right.equalToSuperview().inset(23)
                placeDropdownHeightConstraint = $0.height.equalTo(0).constraint
            }
            contentTopAnchor = placeDropdownTableView.snp.bottom
        } else {
            contentTopAnchor = titleTextField.snp.bottom
        }

        contentTextView.snp.makeConstraints {
            $0.top.equalTo(contentTopAnchor).offset(20)
            $0.left.right.equalToSuperview().inset(23)
            $0.height.equalTo(tipType == .location ? 292 : (tipType.requiresCategorySelection ? 344 : 400))
        }
        
        let anchorView: UIView
        if tipType.requiresCategorySelection {
            categoryCollectionView.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(20)
                $0.left.right.equalToSuperview().inset(23)
                $0.height.equalTo(26)
            }
            anchorView = categoryCollectionView
        } else if tipType.requiresMajorSelection {
            majorCategoryLabel.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(20)
                $0.left.right.equalToSuperview().inset(23)
            }

            majorTextFieldContainer.snp.makeConstraints {
                $0.top.equalTo(majorCategoryLabel.snp.bottom).offset(8)
                $0.left.right.equalToSuperview().inset(23)
                $0.height.equalTo(40)
            }

            majorTextField.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            }

            majorChipsScrollView.snp.makeConstraints {
                $0.top.equalTo(majorTextFieldContainer.snp.bottom).offset(8)
                $0.left.right.equalToSuperview().inset(23)
                majorChipsHeightConstraint = $0.height.equalTo(0).constraint
            }

            majorChipsStackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalToSuperview()
            }

            majorDropdownTableView.snp.makeConstraints {
                $0.top.equalTo(majorChipsScrollView.snp.bottom).offset(8)
                $0.left.right.equalToSuperview().inset(23)
                majorDropdownHeightConstraint = $0.height.equalTo(0).constraint
            }
            anchorView = majorDropdownTableView
        } else {
            anchorView = contentTextView
        }

        imageScrollView.snp.makeConstraints {
            $0.top.equalTo(anchorView.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(23)
            $0.height.equalTo(56)
        }

        imageStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        addImageButton.snp.makeConstraints {
            $0.width.height.equalTo(56)
        }

        shareButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(30)
            shareButtonBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-19).constraint
            $0.height.equalTo(52)
        }
    }

    private func setupObservers() {
        titleTextField.onTextChanged = { [weak self] in self?.updateShareButtonState() }
        contentTextView.onTextChanged = { [weak self] in self?.updateShareButtonState() }
        if tipType == .location {
            placeTextField.onTextChanged = { [weak self] in
                guard let self else { return }
                if self.isApplyingSelectedPlace { return }
                self.selectedPlace = nil
                self.searchPlacesForLocationField()
            }
            placeTextField.textFieldRef.delegate = self
            placeDropdownTableView.dataSource = self
            placeDropdownTableView.delegate = self
            placeDropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        }
    }

    private func bindMajorCategoryUI() {
        majorCategoryLabel.isHidden = false
        majorTextFieldContainer.isHidden = false
        majorTextField.delegate = self
        majorTextField.addTarget(self, action: #selector(didChangeMajorTextField), for: .editingChanged)
        majorDropdownTableView.dataSource = self
        majorDropdownTableView.delegate = self
        majorDropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MajorCell")
    }

    private func fetchMajors() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let majors = try await tipService.majors()
                self.allMajors = majors
                self.filteredMajors = majors
                self.reloadMajorDropdown()
            } catch {
                self.showMajorLoadFailedAlert(error)
            }
        }
    }

    @objc private func didChangeMajorTextField() {
        filterMajors(with: majorTextField.text ?? "")
    }

    private func filterMajors(with query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            filteredMajors = allMajors.filter { major in
                !selectedMajors.contains(where: { $0.id == major.id })
            }
        } else {
            filteredMajors = allMajors.filter { major in
                let notSelected = !selectedMajors.contains(where: { $0.id == major.id })
                return notSelected && major.name.localizedCaseInsensitiveContains(trimmed)
            }
        }
        reloadMajorDropdown()
    }

    private func reloadMajorDropdown() {
        majorDropdownTableView.reloadData()
        let shouldShow = tipType == .major && majorTextField.isFirstResponder && !filteredMajors.isEmpty
        majorDropdownTableView.isHidden = !shouldShow
        majorDropdownHeightConstraint?.update(offset: shouldShow ? min(CGFloat(filteredMajors.count) * 40, 160) : 0)
        view.layoutIfNeeded()
    }

    private func renderSelectedMajorChips() {
        majorChipsStackView.arrangedSubviews.forEach {
            majorChipsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, major) in selectedMajors.enumerated() {
            let button = UIButton(type: .system).then {
                var configuration = UIButton.Configuration.plain()
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
                $0.configuration = configuration
                $0.setTitle("\(major.name) ×", for: .normal)
                $0.setTitleColor(.black800, for: .normal)
                $0.titleLabel?.font = .style(.body4)
                $0.backgroundColor = .orange200
                $0.layer.cornerRadius = 4
                $0.tag = index
            }
            button.addTarget(self, action: #selector(didTapRemoveMajorChip(_:)), for: .touchUpInside)
            majorChipsStackView.addArrangedSubview(button)
        }

        let hasSelectedMajors = !selectedMajors.isEmpty
        majorChipsScrollView.isHidden = !hasSelectedMajors
        majorChipsHeightConstraint?.update(offset: hasSelectedMajors ? 28 : 0)
        view.layoutIfNeeded()
    }

    @objc private func didTapRemoveMajorChip(_ sender: UIButton) {
        let index = sender.tag
        guard index < selectedMajors.count else { return }
        selectedMajors.remove(at: index)
        filterMajors(with: majorTextField.text ?? "")
    }

    private func searchPlacesForLocationField() {
        guard tipType == .location else { return }
        let query = placeTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)

        placeSearchTask?.cancel()
        guard !query.isEmpty else {
            placeResults = []
            placeDropdownTableView.isHidden = true
            placeDropdownHeightConstraint?.update(offset: 0)
            view.layoutIfNeeded()
            return
        }

        placeSearchTask = Task { [weak self] in
            guard let self else { return }

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query

            do {
                let response = try await MKLocalSearch(request: request).start()
                let mapped = response.mapItems.compactMap { item -> PlaceSearchItem? in
                    guard let location = item.placemark.location else { return nil }
                    let name = item.name ?? query
                    let address = item.placemark.title ?? ""
                    let naverMapURL = "https://map.naver.com/v5/search/\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
                    return PlaceSearchItem(
                        name: name,
                        address: address,
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        naverMapURL: naverMapURL
                    )
                }

                self.placeResults = Array(mapped.prefix(8))
                self.placeDropdownTableView.reloadData()
                let shouldShow = !self.placeResults.isEmpty && self.placeTextField.textFieldRef.isFirstResponder
                self.placeDropdownTableView.isHidden = !shouldShow
                self.placeDropdownHeightConstraint?.update(offset: shouldShow ? min(CGFloat(self.placeResults.count) * 44, 220) : 0)
                self.view.layoutIfNeeded()
            } catch {
                self.placeResults = []
                self.placeDropdownTableView.reloadData()
                self.placeDropdownTableView.isHidden = true
                self.placeDropdownHeightConstraint?.update(offset: 0)
                self.view.layoutIfNeeded()
            }
        }
    }

    private func updateShareButtonState() {
        let isTitleFilled   = !titleTextField.text.isEmpty
        let isContentFilled = !contentTextView.text.isEmpty
        let isCategoryValid = tipType.requiresCategorySelection ? selectedCategory != nil : true
        let isMajorValid = tipType.requiresMajorSelection ? !selectedMajors.isEmpty : true
        let isLocationValid = tipType == .location
            ? !placeTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            : true
        let isEnabled = isTitleFilled && isContentFilled && isCategoryValid && isMajorValid && isLocationValid

        shareButton.isEnabled = isEnabled
    }

    private func resolveLocationPlaceIfNeeded() async throws -> PlaceSearchItem {
        if let selectedPlace {
            return selectedPlace
        }

        let query = placeTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            throw WriteUploadError.missingLocationPlace
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let response = try await MKLocalSearch(request: request).start()

        guard let first = response.mapItems.first,
              let location = first.placemark.location else {
            throw WriteUploadError.missingLocationPlace
        }

        let name = first.name ?? query
        let address = first.placemark.title ?? ""
        let naverMapURL = "https://map.naver.com/v5/search/\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
        let resolved = PlaceSearchItem(
            name: name,
            address: address,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            naverMapURL: naverMapURL
        )
        selectedPlace = resolved
        return resolved
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAddImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func didTapShare() {
        let popupView = NSGPopupView(
            title: "게시물 작성",
            message: "익명으로 작성하시겠습니까?\n아니오를 누르면 실명과 기수가 노출됩니다.",
            cancelButtonTitle: "실명공개",
            confirmButtonTitle: "익명작성",
            cancelAction: { [weak self] in
                self?.submitTip(isAnonymous: false)
            },
            confirmAction: { [weak self] in
                self?.submitTip(isAnonymous: true)
            }
        )
        popupView.show(in: view)
    }

    private func submitTip(isAnonymous: Bool) {
        guard shareButton.isEnabled else { return }

        let title = titleTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !body.isEmpty else { return }

        shareButton.isEnabled = false

        Task { [weak self] in
            guard let self else { return }

            do {
                let uploadableImageURLs = try await buildUploadableImageURLs()

                if tipType == .location {
                    let selectedPlace = try await resolveLocationPlaceIfNeeded()
                    guard let selectedCategory else { throw WriteUploadError.invalidLocationCategory }

                    let placeResponse = try await tipService.createPlace(
                        request: CreatePlaceRequest(
                            title: selectedPlace.name,
                            description: body,
                            category: selectedCategory.placeAPICategory,
                            latitude: selectedPlace.latitude,
                            longitude: selectedPlace.longitude,
                            naverMapURL: selectedPlace.naverMapURL,
                            isAnonymous: isAnonymous
                        )
                    )

                    let request = CreateTipRequest(
                        title: title,
                        body: body,
                        category: tipType.apiCategory,
                        isAnonymous: isAnonymous,
                        placeID: placeResponse.id,
                        imageURLs: uploadableImageURLs
                    )
                    _ = try await tipService.createTip(request: request)
                } else if tipType == .major {
                    let request = CreateMajorPostRequest(
                        title: title,
                        body: body,
                        majorIDs: selectedMajors.map(\.id),
                        isAnonymous: isAnonymous,
                        imageURLs: uploadableImageURLs
                    )
                    _ = try await tipService.createMajorPost(request: request)
                } else {
                    let request = CreateTipRequest(
                        title: title,
                        body: body,
                        category: tipType.apiCategory,
                        isAnonymous: isAnonymous,
                        placeID: nil,
                        imageURLs: uploadableImageURLs
                    )
                    _ = try await tipService.createTip(request: request)
                }
                await MainActor.run {
                    self.showCreatedAlert()
                }
            } catch {
                await MainActor.run {
                    self.updateShareButtonState()
                    self.showCreateFailedAlert(error)
                }
            }
        }
    }

    private func buildUploadableImageURLs() async throws -> [String] {
        var result: [String] = []

        for (index, image) in selectedImages.enumerated() {
            let sourceURL = index < selectedImageURLs.count ? selectedImageURLs[index] : nil
            if let sourceURL, isRemoteURL(sourceURL) {
                result.append(sourceURL)
                continue
            }

            guard let data = image.jpegData(compressionQuality: 0.8) else {
                throw WriteUploadError.invalidImageData
            }
            let fileName = "\(UUID().uuidString).jpg"
            let uploadedURL = try await tipService.uploadImage(
                data: data,
                fileName: fileName,
                mimeType: "image/jpeg"
            )
            result.append(uploadedURL)
        }

        for sourceURL in selectedImageURLs where isRemoteURL(sourceURL) && !result.contains(sourceURL) {
            result.append(sourceURL)
        }

        return result
    }

    private func isRemoteURL(_ raw: String) -> Bool {
        guard let url = URL(string: raw), let scheme = url.scheme?.lowercased() else {
            return false
        }
        return scheme == "http" || scheme == "https"
    }

    private func showCreatedAlert() {
        let alert = UIAlertController(
            title: "작성 완료",
            message: "게시글이 등록되었습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }

    private func showCreateFailedAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "작성 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showMajorLoadFailedAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "전공 목록 불러오기 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension WriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        let imageURL = (info[.imageURL] as? URL)?.absoluteString
        addImageThumbnail(image, imageURL: imageURL)
    }

    private func addImageThumbnail(_ image: UIImage, imageURL: String?) {
        selectedImages.append(image)
        selectedImageURLs.append(imageURL ?? "")

        let container = UIView()
        let imageView = UIImageView(image: image).then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
        }
        let removeButton = UIButton(type: .system).then {
            $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            $0.tintColor = .white
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            $0.layer.cornerRadius = 10
        }
        removeButton.tag = selectedImages.count - 1
        removeButton.addTarget(self, action: #selector(removeImage(_:)), for: .touchUpInside)

        container.addSubview(imageView)
        container.addSubview(removeButton)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        removeButton.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(4)
            $0.width.height.equalTo(20)
        }
        container.snp.makeConstraints { $0.width.height.equalTo(56) }

        imageStackView.insertArrangedSubview(container, at: imageStackView.arrangedSubviews.count - 1)
    }

    @objc private func removeImage(_ sender: UIButton) {
        let index = sender.tag
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        if index < selectedImageURLs.count {
            selectedImageURLs.remove(at: index)
        }
        let viewToRemove = imageStackView.arrangedSubviews[index]
        imageStackView.removeArrangedSubview(viewToRemove)
        viewToRemove.removeFromSuperview()
    }
}

extension WriteViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === majorTextField {
            filterMajors(with: majorTextField.text ?? "")
            return
        }

        if textField === placeTextField.textFieldRef {
            searchPlacesForLocationField()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === majorTextField {
            majorDropdownTableView.isHidden = true
            majorDropdownHeightConstraint?.update(offset: 0)
            view.layoutIfNeeded()
            return
        }

        if textField === placeTextField.textFieldRef {
            placeDropdownTableView.isHidden = true
            placeDropdownHeightConstraint?.update(offset: 0)
            view.layoutIfNeeded()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === majorDropdownTableView {
            return filteredMajors.count
        }
        if tableView === placeDropdownTableView {
            return placeResults.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === majorDropdownTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MajorCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = filteredMajors[indexPath.row].name
            content.textProperties.font = .style(.body3)
            content.textProperties.color = .black700
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = placeResults[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = place.name
        content.secondaryText = place.address
        content.textProperties.font = .style(.body3)
        content.textProperties.color = .black800
        content.secondaryTextProperties.font = .style(.body4)
        content.secondaryTextProperties.color = .black500
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === majorDropdownTableView {
            let selected = filteredMajors[indexPath.row]
            selectedMajors.append(.init(id: selected.id, name: selected.name))
            majorTextField.text = ""
            filterMajors(with: "")
            return
        }

        if tableView === placeDropdownTableView {
            let selected = placeResults[indexPath.row]
            isApplyingSelectedPlace = true
            selectedPlace = selected
            placeTextField.setText(selected.name)
            isApplyingSelectedPlace = false
            placeTextField.textFieldRef.resignFirstResponder()
            placeResults = []
            placeDropdownTableView.reloadData()
            placeDropdownTableView.isHidden = true
            placeDropdownHeightConstraint?.update(offset: 0)
            view.layoutIfNeeded()
        }
    }
}

extension WriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return LocationCategory.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LocationCategoryCell.identifier, for: indexPath
        ) as! LocationCategoryCell
        let category = LocationCategory.allCases[indexPath.item]
        cell.configure(category: category, isSelected: selectedCategory == category)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let tapped = LocationCategory.allCases[indexPath.item]
        selectedCategory = selectedCategory == tapped ? nil : tapped
        collectionView.reloadData()
    }
}

private extension TipType {
    var requiresMajorSelection: Bool {
        self == .major
    }

    var apiCategory: String {
        switch self {
        case .location:
            return "PLACE"
        case .dormitory:
            return "DORM_LIFE"
        case .school:
            return "SCHOOL_LIFE"
        case .major:
            return "SCHOOL_LIFE"
        case .etc:
            return "ETC"
        }
    }
}

private extension LocationCategory {
    var placeAPICategory: String {
        switch self {
        case .cafe:
            return "CAFE"
        case .pcRoom:
            return "PC_ROOM"
        case .karaoke:
            return "KARAOKE"
        case .restaurant:
            return "RESTAURANT"
        case .etc:
            return "ETC"
        }
    }
}
