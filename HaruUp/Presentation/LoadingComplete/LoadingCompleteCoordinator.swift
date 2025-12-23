//
//  LoadingCompleteCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/24/25.
//

import UIKit


final class LoadingCompleteCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    var onFinsh: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
//        let loadingCompleteVM = LoadingCompleteViewModel()
        let loadingCompleteVC = LoadingCompleteViewController()
        
        navigationController.setViewControllers([loadingCompleteVC], animated: true)
        
        
    }
    
}
