//
//  GoalSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class GoalSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    private let selectedInterestDetail: String
    
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, selectedInterestDetail: String, curationData: CurationData) {
        self.navigationController = navigationController
        self.selectedInterestDetail = selectedInterestDetail
        self.curationData = curationData
    }
    
    func start() {
        print("🟡 GoalSelectCoordinator start() 호출됨")
        print("🟡 선택된 세부 관심사: \(selectedInterestDetail)")
        let goalSelectVM = GoalSelectViewModel(
            coordinator: self,
            selectedInterestDetail: selectedInterestDetail
        )
        
        let goalSelectVC = GoalSelectViewController(viewModel: goalSelectVM)
        
        print("🟡 GoalSelectViewController 생성 완료")
        print("🟡 push 시작")
        navigationController.pushViewController(goalSelectVC, animated: true)
    }
    
    // 다음 화면으로 이동
    func showNextFlow(selectedGoal: String) {
        print("선택된 세부 직무: \(selectedInterestDetail), 선택된 목표: \(selectedGoal)")
        
        
        curationData.goal = selectedGoal
        print("📦 저장된 데이터 - 목표: \(selectedGoal)")
        
        
        print("📦 ===== 최종 수집된 데이터 ===== 📦")
        print("캐릭터 ID: \(curationData.characterId ?? -1)")
        print("닉네임: \(curationData.nickname ?? "없음")")
        print("직업: \(curationData.job ?? "없음")")
        print("세부 직무: \(curationData.jobDetail ?? "없음")")
        print("성별: \(curationData.gender ?? "없음")")
        print("생년월일: \(curationData.birthDate ?? "없음")")
        print("관심사: \(curationData.interest ?? "없음")")
        print("세부 관심사: \(curationData.interestDetail ?? "없음")")
        print("목표: \(curationData.goal ?? "없음")")
        print("직접 입력 목표: \(curationData.goalInput ?? "없음")")
        print("📦 ========================== 📦")
        
        // 온보딩 완료!!
        TokenStorageService.shared.saveOnboardingCompleted(true)
        print("✅온보딩 완료!! - onboardingCompleted: \(TokenStorageService.shared.isOnboardingCompleted)")
        
        onFinish?(curationData)
    }
    
    func showGoalInputFlow(selectedGoal: String) {
        let goalInputCoordinator = GoalInputSelectCoordinator(navigationController: navigationController, curationData: curationData)
        
        curationData.goal = selectedGoal
        
        goalInputCoordinator.onFinish = { [weak self, weak goalInputCoordinator] curationData in
            if let coordinator = goalInputCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(goalInputCoordinator)
        goalInputCoordinator.start()
    }
}

