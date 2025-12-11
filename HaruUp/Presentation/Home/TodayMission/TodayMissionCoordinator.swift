//
//  TodayMissionCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import UIKit

final class TodayMissionCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    var onFinish: (() -> Void)? // 미션 선택 완료 후 동작
    
    private let missionService: MissionServiceProtocol
    
    init(navigationController: UINavigationController, missionService: MissionServiceProtocol) {
        self.navigationController = navigationController
        self.missionService = missionService
    }
    
    func start() {
        showIntro()
    }
    
    private func showIntro() {
        let viewModel = TodayMissionIntroViewModel()
        let viewcController = TodayMissionIntroViewController(viewModel: viewModel)
        viewcController.isModalInPresentation = true
        
        viewcController.onSelectMissionTap = { [weak self] in
            self?.showMissionList()
        }
        
        navigationController.setViewControllers([viewcController], animated: false)
    }
    
    private func showMissionList() {
        let viewModel = TodayMissionListViewModel(missionService: missionService)
        let viewController = TodayMissionListViewController(viewModel: viewModel)
        
        viewController.onComplete = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
