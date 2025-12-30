//
//  SplashCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/11/25.
//

import UIKit


final class SplashCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    // AppCoordinator에게 전달
    var onFinish: ((SplashResult) -> Void)?
    
    private weak var splashViewController: SplashViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = SplashViewModel()
        let vc = SplashViewController(viewModel: viewModel)
        
        // SplashVC에서 결과 받기
        vc.onAuthCheckCompleted = { [weak self] result in
            self?.onFinish?(result)
        }
        
        navigationController.setViewControllers([vc], animated: false)
    }
}
