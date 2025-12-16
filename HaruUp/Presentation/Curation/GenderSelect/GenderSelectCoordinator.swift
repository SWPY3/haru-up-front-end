//
//  GenderSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class GenderSelectCoordinator: Coordinator {

    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let genderSelectVM = GenderSelectViewModel()
        let genderSelectVC = GenderSelectViewController(viewModel: genderSelectVM)
        navigationController.pushViewController(genderSelectVC, animated: true)
    }
}
