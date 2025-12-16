//
//  JobSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit


final class JobSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let jobSelectVM = JobSelectViewModel()
        let jobSelectVC = JobSelectViewController(viewModel: jobSelectVM)
        
        navigationController.setViewControllers([jobSelectVC], animated: false)
    }
}
