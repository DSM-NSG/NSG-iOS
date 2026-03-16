//
//  TabbarViewController.swift
//  NSG
//
//  Created by hawon on 3/11/26.
//

import UIKit

final class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabBar()
        setViewControllers(makeTabs(), animated: false)
    }

    private func configureTabBar() {
        tabBar.isTranslucent = false
        tabBar.tintColor = .orange400
        tabBar.unselectedItemTintColor = .black400
    }

    private func makeTabs() -> [UIViewController] {
        let location = makeNav(
            root: LocationViewController(),
            title: "지도",
            imageName: "tabbarLocation"
        )
        let comment = makeNav(
            root: CommentViewController(),
            title: "작성",
            imageName: "tabbarComent"
        )
        let share = makeNav(
            root: ShareViewController(),
            title: "공유",
            imageName: "tabbarShare"
        )
        let major = makeNav(
            root: MajorViewController(),
            title: "전공",
            imageName: "tabbarMajor"
        )
        let my = makeNav(
            root: MyViewController(),
            title: "마이페이지",
            imageName: "tabbarMy"
        )

        return [ location, comment, share, major, my ]
    }

    private func makeNav(
        root: UIViewController,
        title: String,
        imageName: String
    ) -> UIViewController {
        root.title = title
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        )
        return nav
    }
}
private final class LocationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setCenterLabel(text: "지도")
    }
}

private final class CommentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setCenterLabel(text: "작성")
    }
}

private final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setCenterLabel(text: "공유")
    }
}

private final class MajorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setCenterLabel(text: "전공")
    }
}

private final class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setCenterLabel(text: "마이페이지")
    }
}

private extension UIViewController {
    func setCenterLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .black900
        label.font = .style(.header2)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
