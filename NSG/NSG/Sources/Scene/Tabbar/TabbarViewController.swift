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
            root: TipSeletedViewController(),
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
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        )
        return nav
    }
}
