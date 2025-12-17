//
//  BirthSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit



final class BirthSelectCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let birthSelectVM = BirthSelectViewModel()
        let birthSelectVC = BirthSelectViewController(viewModel: birthSelectVM)
        navigationController.pushViewController(birthSelectVC, animated: true)
    }
    
}
