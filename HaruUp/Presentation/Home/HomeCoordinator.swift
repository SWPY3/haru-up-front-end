//
//  HomeCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeVM = HomeViewModel()
        let homeVC = HomeViewController(viewModel: homeVM)
        homeVC.onSelectTodayMission = { [weak self] in
            guard let self else { return }
            self.showTodayMissionFlow()
        }
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    private func showTodayMissionFlow() {
        let modalNavigationController = UINavigationController()
        modalNavigationController.modalPresentationStyle = .overFullScreen

        let coordinator = TodayMissionCoordinator(navigationController: modalNavigationController)

        coordinator.onFinish = { [weak self, weak modalNavigationController, weak coordinator] in
            modalNavigationController?.dismiss(animated: true)
            
            if let coordinator = coordinator {
                if let removable = coordinator as AnyObject? {
                    self?.childCoordinators.removeAll { ($0 as AnyObject) === removable }
                }
            }
        }
        
        childCoordinators.append(coordinator)

        coordinator.start()
        navigationController.present(modalNavigationController, animated: true)
    }
}
