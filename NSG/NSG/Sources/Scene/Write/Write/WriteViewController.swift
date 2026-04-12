//
//  WriteViewController.swift
//  NSG
//
//  Created by hawon on 4/8/26.
//
import UIKit
import SnapKit
import Then

final class WriteViewController: UIViewController {

    private let tipType: TipType
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

    init(tipType: TipType) {
        self.tipType = tipType
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupLayout()
        setupObservers()
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
        // tipType, selectedCategory, titleTextField.text, contentTextView.text, selectedImages 활용
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
