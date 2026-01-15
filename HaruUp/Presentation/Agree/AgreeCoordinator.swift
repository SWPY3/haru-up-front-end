//
//  AgreeCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 1/15/26.
//

import UIKit


final class AgreeCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    var onFinish: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let agreeVM = AgreeViewModel()
        let agreeVC = AgreeViewController(viewModel: agreeVM)
        
        agreeVC.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(agreeVC, animated: true)
    }
}
