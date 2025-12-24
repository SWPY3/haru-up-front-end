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
    
    private let missionService: MissionServiceProtocol = MissionService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeVM = HomeViewModel(missionService: missionService)
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
        modalNavigationController.modalTransitionStyle = .crossDissolve

        let coordinator = TodayMissionCoordinator(navigationController: modalNavigationController, missionService: missionService)

        coordinator.onFinish = { [weak self, weak modalNavigationController, weak coordinator] in
            print("창 종료")
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
