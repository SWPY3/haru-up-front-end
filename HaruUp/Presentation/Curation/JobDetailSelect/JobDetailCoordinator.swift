//
//  JobDetailCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit


final class JobDetailSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let jobDetailSelectVM = JobDetailSelectViewModel()
        let jobDetailSelectVC = JobDetailSelectViewController(viewModel: jobDetailSelectVM)
        
        navigationController.setViewControllers([jobDetailSelectVC], animated: false)
    }
}
