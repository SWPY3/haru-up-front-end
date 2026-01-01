//
//  ChartCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

final class ChartCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let chartVM = ChartViewModel()
        let chartVC = ChartViewController(viewModel: chartVM)
        
        navigationController.setViewControllers([chartVC], animated: false)
    }
}
