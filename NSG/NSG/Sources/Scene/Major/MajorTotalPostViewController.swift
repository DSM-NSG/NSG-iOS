//
//  MajorTotalPostViewController.swift
//  NSG
//
//  Created by Codex on 4/16/26.
//
import UIKit
import SnapKit
import Then

final class MajorTotalPostViewController: UIViewController {

    private let screenTitle: String
    private let posts: [SharePost]

    private let collectionView = UICollectionView(
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
    }

    init(title: String, posts: [SharePost]) {
        self.screenTitle = title
        self.posts = posts
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = screenTitle
        view.backgroundColor = .background
        navigationItem.largeTitleDisplayMode = .never

        addView()
        setLayout()
        configureUI()
    }

    private func addView() {
        view.addSubview(collectionView)
    }

    private func setLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
    }

    private func configureUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LatestPostCell.self, forCellWithReuseIdentifier: LatestPostCell.identifier)
    }
}

extension MajorTotalPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LatestPostCell.identifier,
            for: indexPath
        ) as? LatestPostCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: posts[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(post: posts[indexPath.item])
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
