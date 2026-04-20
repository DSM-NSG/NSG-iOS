//
//  WriteViewController.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit
import SnapKit
import Then

@MainActor
final class WriteViewController: UIViewController {

    private let tipType: TipType
    private let tipService: TipServicing
    private var selectedImages: [UIImage] = []
    private var shareButtonBottomConstraint: Constraint?
    private var selectedCategory: LocationCategory? {
        didSet { updateShareButtonState() }
    }

    private let titleTextField = NSGSingleTextField(placeholder: "제목")
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
        if tipType.requiresCategorySelection {
            view.addSubview(categoryCollectionView)
        }
        view.addSubview(contentTextView)
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

        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(23)
            $0.height.equalTo(tipType.requiresCategorySelection ? 344 : 400)
        }
        
        let anchorView: UIView
        if tipType.requiresCategorySelection {
            categoryCollectionView.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(20)
                $0.left.right.equalToSuperview().inset(23)
                $0.height.equalTo(26)
            }
            anchorView = categoryCollectionView
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
    }
    private func updateShareButtonState() {
        let isTitleFilled   = !titleTextField.text.isEmpty
        let isContentFilled = !contentTextView.text.isEmpty
        let isCategoryValid = tipType.requiresCategorySelection ? selectedCategory != nil : true
        let isEnabled = isTitleFilled && isContentFilled && isCategoryValid

        shareButton.isEnabled = isEnabled
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

        let request = CreateTipRequest(
            title: title,
            body: body,
            category: tipType.apiCategory,
            isAnonymous: isAnonymous,
            placeID: nil,
            imageURLs: []
        )

        shareButton.isEnabled = false

        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await tipService.createTip(request: request)
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
}

extension WriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        addImageThumbnail(image)
    }

    private func addImageThumbnail(_ image: UIImage) {
        selectedImages.append(image)

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
        let viewToRemove = imageStackView.arrangedSubviews[index]
        imageStackView.removeArrangedSubview(viewToRemove)
        viewToRemove.removeFromSuperview()
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
