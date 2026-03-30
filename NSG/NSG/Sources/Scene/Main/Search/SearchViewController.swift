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
    }
}
