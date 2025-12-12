//
//  SplashViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/11/25.
//

import UIKit

class SplashViewController: UIViewController {
    
    let viewModel: SplashViewModel
    
    let mainLogoLabel: UILabel = {
        let label = UILabel()
        label.text = "어플 로고 자리입니다~"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mainLogoLabel)
        configureMainLogo()
    }
    
    func configureMainLogo() {
        mainLogoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainLogoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
