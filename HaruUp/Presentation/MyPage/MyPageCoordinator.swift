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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let myPageVM = MyPageViewModel()
        let myPageVC = MyPageViewController(viewModel: myPageVM)
        
        navigationController.setViewControllers([myPageVC], animated: false)
    }
}
