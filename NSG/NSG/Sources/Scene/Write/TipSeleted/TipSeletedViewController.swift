import UIKit
import SnapKit
import Then

class TipSeletedViewController: UIViewController {

    // MARK: - UI

    private let titleLabel = UILabel().then {
        $0.text = "꿀팁 작성"
        $0.font = .style(.header1)
        $0.textColor = .black800
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        addView()
        setLayout()
    }

    // MARK: - Setup

    private func addView() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        TipType.allCases.forEach { type in
            let button = TipButton(
                icon: UIImage(named: type.iconName),
                previewImage: UIImage(named: type.previewImageName),
                text: type.buttonText
            )
            button.addTarget(self, action: #selector(didTapTipButton(_:)), for: .touchUpInside)
            // tag로 TipType 인덱스 저장
            button.tag = TipType.allCases.firstIndex(of: type) ?? 0
            stackView.addArrangedSubview(button)
        }
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(24)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 24, right: 24))
        }
    }

    // MARK: - Action

    @objc private func didTapTipButton(_ sender: UIButton) {
        let type = TipType.allCases[sender.tag]
        let vc = WriteViewController(tipType: type)
        navigationController?.pushViewController(vc, animated: true)
    }
}
