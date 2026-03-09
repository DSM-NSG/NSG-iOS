//
//  ViewController.swift
//  NSG
//
//  Created by hawon on 3/9/26.
//

import UIKit
import Then
import SnapKit

class SplashViewController: UIViewController {

    let logoImage = UIImageView().then {
        $0.image = UIImage(named: "logo")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addView()
        setLayout()
        configuration()
        
    }

    private func addView()  {
        view.addSubview(logoImage)
    }

    private func setLayout() {
        logoImage.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func configuration() {
        view.backgroundColor = .background
    }

}

