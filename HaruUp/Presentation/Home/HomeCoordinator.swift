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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeVM = HomeViewModel(missionService: missionService, interestsService: interestsService)
        let homeVC = HomeViewController(viewModel: homeVM)
        homeVC.onSelectTodayMission = { [weak self] in
            guard let self else { return }
            self.showTodayMissionFlow {
                homeVC.didCompleteMissionSelection()
            }
        }
        
        homeVC.onShowBottomSheet = { [weak self, weak homeVC] mission in
            self?.presentMissionBottomSheet(mission: mission, onActionCompleted: {
                // 바텀시트에서 완료/삭제가 일어나면 HomeVC를 갱신
                homeVC?.didCompleteMissionSelection()
            })
        }
        
        homeVC.onShowChallengeBottomSheet = { [weak self] data in
            self?.presentChallengeBottomSheet(weeklyData: data)
        }
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    private func showTodayMissionFlow(onDismiss: @escaping () -> Void) {
        let modalNavigationController = UINavigationController()
        modalNavigationController.modalPresentationStyle = .overFullScreen
        modalNavigationController.modalTransitionStyle = .crossDissolve

        let coordinator = TodayMissionCoordinator(navigationController: modalNavigationController, missionService: missionService, interestsService: interestsService)

        coordinator.onFinish = { [weak self, weak modalNavigationController, weak coordinator] in
            print("창 종료")
            modalNavigationController?.dismiss(animated: true, completion: {
                onDismiss() // 해당 위치에서 갱신 요청
            })
            
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
    
    private func presentChallengeBottomSheet(weeklyData: [DailyMissionData]) {
        let bottomSheetVC = MissionDayBottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.weeklyData = weeklyData
        
        navigationController.present(bottomSheetVC, animated: false)
    }
}

