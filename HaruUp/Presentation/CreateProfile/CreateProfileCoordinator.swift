//
//  CreateProfileCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit


final class CreateProfileCoordinator: Coordinator {
    
    let navigationController: UINavigationController

    var childCoordinators: [any Coordinator] = []

    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let createProfileVC = CreateProfileViewController()
        let createProfileVM = CreateProfileViewModel()
        
        navigationController.setViewControllers([createProfileVC], animated: false)
    }

}
