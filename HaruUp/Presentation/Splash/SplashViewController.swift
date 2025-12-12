//
//  SplashViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/11/25.
//

import UIKit

class SplashViewController: UIViewController {

    let mainLogoLabel: UILabel = {
        let label = UILabel()
        label.text = "어플 로고 자리입니다~"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mainLogoLabel)
    }
    
    func configureMainLogo() {
        mainLogoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainLogoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
