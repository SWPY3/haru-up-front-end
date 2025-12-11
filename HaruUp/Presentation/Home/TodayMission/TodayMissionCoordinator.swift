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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showIntro()
    }
    
    private func showIntro() {
        let vm = TodayMissionIntroViewModel()
        let vc = TodayMissionIntroViewController(viewModel: vm)
        
        // 스와이프로 내려서 닫기 방지 (무조건 진행하게)
        vc.isModalInPresentation = true
        
//        vc.onSelectMissionTap = { [weak self] in
//            self?.showMissionList()
//        }
        
        navigationController.setViewControllers([vc], animated: false)
    }
    
    private func showMissionList() {
        let vm = TodayMissionListViewModel()
        let vc = TodayMissionListViewController(viewModel: vm)
        
//        vc.onComplete = { [weak self] selectedMissions in
//            // 1) 오늘 미션 저장
//            self?.missionService.saveTodayMissions(selectedMissions)
//            // 2) 부모에 종료 알림
//            self?.onFinish?()
//        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
