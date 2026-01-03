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
    private let interestsService: InterestsService = InterestsService()
    private let memberService: MemberService = MemberService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeVM = HomeViewModel(missionService: missionService, interestsService: interestsService, memberService: memberService)
        let homeVC = HomeViewController(viewModel: homeVM)
        
        homeVC.onSelectTodayMission = { [weak self] in
            guard let self else { return }
            self.showTodayMissionFlow(preSelectedIDs: []) {
                homeVC.didCompleteMissionSelection()
            }
        }
        
        homeVC.onShowBottomSheet = { [weak self, weak homeVC] mission in
            self?.presentMissionBottomSheet(mission: mission, onActionCompleted: {
                // 바텀시트에서 완료/삭제가 일어나면 HomeVC를 갱신
                homeVC?.didCompleteMissionSelection()
            })
        }
        
        homeVC.onShowChallengeBottomSheet = { [weak self] count, data in
            self?.presentChallengeBottomSheet(countDay: count, weeklyData: data)
        }
        
        homeVC.onShowAddMission = { [weak self] currentIDs in
            guard let self else { return }
            
            self.showTodayMissionFlow(preSelectedIDs: currentIDs) {
                homeVC.didCompleteMissionSelection()
            }
        }
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    /// 통합된 미션 플로우 실행 함수
    /// - Parameter preSelectedIDs: 비어있으면 초기 진입(Intro O), 값이 있으면 추가 모드(Intro X)
    private func showTodayMissionFlow(preSelectedIDs: [Int], onDismiss: @escaping () -> Void) {
        let modalNavigationController = UINavigationController()
        modalNavigationController.modalPresentationStyle = .overFullScreen
        modalNavigationController.modalTransitionStyle = .crossDissolve
        
        // Coordinator 생성 시 ID 목록 전달
        let coordinator = TodayMissionCoordinator(
            navigationController: modalNavigationController,
            missionService: missionService,
            interestsService: interestsService,
            preSelectedIDs: preSelectedIDs
        )
        
        coordinator.onFinish = { [weak self, weak modalNavigationController, weak coordinator] in
            modalNavigationController?.dismiss(animated: true, completion: {
                onDismiss() // Home 화면 갱신 요청
            })
            
            if let coordinator = coordinator {
                if let removable = coordinator as AnyObject? {
                    self?.childCoordinators.removeAll { ($0 as AnyObject) === removable }
                }
            }
        }
        
        childCoordinators.append(coordinator)
        
        coordinator.start() // 내부에서 ID 유무에 따라 Intro/List 분기
        navigationController.present(modalNavigationController, animated: true)
    }

    private func presentMissionBottomSheet(mission: Mission, onActionCompleted: @escaping () -> Void) {
        let bottomSheetViewModel = MissionBottomSheetViewModel(
            mission: mission,
            missionService: self.missionService
        )
        let bottomSheetVC = MissionBottomSheetViewController(viewModel: bottomSheetViewModel)
        
        bottomSheetVC.onMissionStatusChanged = {
            onActionCompleted()
        }
        
        navigationController.present(bottomSheetVC, animated: false)
    }
    
    private func presentChallengeBottomSheet(countDay: Int, weeklyData: [DailyMissionData]) {
        let bottomSheetVC = MissionDayBottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.countDay = countDay
        bottomSheetVC.weeklyData = weeklyData
        
        navigationController.present(bottomSheetVC, animated: false)
    }
}

