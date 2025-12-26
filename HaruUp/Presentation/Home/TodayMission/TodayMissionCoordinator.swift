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
    private let interestsService: InterestsService
    
    init(navigationController: UINavigationController, missionService: MissionServiceProtocol, interestsService: InterestsService) {
        self.navigationController = navigationController
        self.missionService = missionService
        self.interestsService = interestsService
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
        let viewModel = TodayMissionListViewModel(missionService: missionService, interestsService: interestsService)
        let viewController = TodayMissionListViewController(viewModel: viewModel)
        
        viewController.onComplete = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
