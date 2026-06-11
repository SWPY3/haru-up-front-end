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

    /// 챗봇 완료 후 직접 주입되는 미션 목록
    private let chatbotMissions: [ChatbotMissionDto]?

    init(navigationController: UINavigationController,
         missionService: MissionServiceProtocol,
         interestsService: InterestsService,
         preSelectedIDs: [Int] = [],
         chatbotMissions: [ChatbotMissionDto]? = nil) {

        self.navigationController = navigationController
        self.missionService = missionService
        self.interestsService = interestsService
        self.preSelectedIDs = preSelectedIDs
        self.chatbotMissions = chatbotMissions
    }

    func start() {
        // 챗봇 플로우: Intro 생략하고 바로 미션 목록
        if chatbotMissions != nil {
            showMissionList()
        // 추가 모드: 이미 선택된 ID가 있는 경우 Intro 생략
        } else if !preSelectedIDs.isEmpty {
            showMissionList()
        // 오늘 이미 Intro를 본 경우 생략
        } else if hasShownIntroToday() {
            showMissionList()
        } else {
            markIntroShownToday()
            showIntro()
        }
    }

    private func hasShownIntroToday() -> Bool {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let lastShownDate = UserDefaults.standard.string(forKey: UserDefaultsKey.lastIntroShownDate)
        return lastShownDate == today
    }

    private func markIntroShownToday() {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        UserDefaults.standard.set(today, forKey: UserDefaultsKey.lastIntroShownDate)
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
        let viewModel = TodayMissionListViewModel(
            missionService: missionService,
            interestsService: interestsService,
            preSelectedMissionIDs: preSelectedIDs,
            chatbotMissions: chatbotMissions
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
