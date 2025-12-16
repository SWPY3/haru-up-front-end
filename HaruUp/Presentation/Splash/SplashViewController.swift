//
//  SplashViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/11/25.
//

import UIKit
import RxSwift

class SplashViewController: UIViewController {
    
    let viewModel: SplashViewModel
    private let disposeBag = DisposeBag()
    
    // coordinator에게 결과 전달
    var onAuthCheckCompleted: ((SplashResult) -> Void)?
    
    let mainLogoImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ex_logo")
        iv.contentMode = .scaleAspectFit
        return iv
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

        view.addSubview(mainLogoImage)
        configureMainLogo()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 인증 상태 확인
        viewModel.checkAuthStatus()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.onAuthCheckCompleted?(result)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func configureMainLogo() {
        mainLogoImage.translatesAutoresizingMaskIntoConstraints = false

        mainLogoImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        mainLogoImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        mainLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
