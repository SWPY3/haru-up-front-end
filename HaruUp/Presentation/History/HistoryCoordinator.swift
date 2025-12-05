//
//  HistoryCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

final class HistoryCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let historyVM = HistoryViewModel()
        let historyVC = HistoryViewController(viewModel: historyVM)
        
        navigationController.setViewControllers([historyVC], animated: false)
    }
}
