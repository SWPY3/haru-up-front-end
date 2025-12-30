//
//  MyPageCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    let curationData: CurationData
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        let myPageVM = MyPageViewModel(curationData: curationData)
        let myPageVC = MyPageViewController(viewModel: myPageVM)
        
        navigationController.setViewControllers([myPageVC], animated: false)
    }
}
