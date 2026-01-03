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
    
    /// 이전에 선택된 미션 ID 목록 (추가 모드일 때 사용)
    private let preSelectedIDs: [Int]
    
    init(navigationController: UINavigationController,
         missionService: MissionServiceProtocol,
         interestsService: InterestsService,
         preSelectedIDs: [Int] = []) {
        
        self.navigationController = navigationController
        self.missionService = missionService
        self.interestsService = interestsService
        self.preSelectedIDs = preSelectedIDs
    }
    
    func start() {
        // 이미 선택된 ID가 있다면 (미션 추가 모드) -> Intro 생략하고 바로 리스트로
        if !preSelectedIDs.isEmpty {
            showMissionList()
        } else {
            // 처음 진입하는 경우 -> Intro 부터 시작
            showIntro()
        }
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
        // ViewModel에 preSelectedMissionIDs 전달
        let viewModel = TodayMissionListViewModel(
            missionService: missionService,
            interestsService: interestsService,
            preSelectedMissionIDs: preSelectedIDs // <- ViewModel에 전달
        )
        let viewController = TodayMissionListViewController(viewModel: viewModel)
        
        viewController.onComplete = { [weak self] in
            self?.onFinish?()
        }
        
        // preSelectedIDs가 있다면(추가 모드) Intro가 없으므로 첫 화면이 됨 -> setViewControllers
        // 없다면(기본 모드) Intro 다음이므로 -> pushViewController
        if !preSelectedIDs.isEmpty {
            navigationController.setViewControllers([viewController], animated: false)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
