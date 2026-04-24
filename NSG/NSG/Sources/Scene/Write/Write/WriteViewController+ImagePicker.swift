import UIKit
import SnapKit
import Then

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
