//
//  GoalInputSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class GoalInputSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    func start() {
        print("🟡 GoalLInputSelectCoordinator start() 호출됨")
        print("🟡 목표 직접 입력할게요 선택")
        let goalInputSelectVM = GoalInputSelectViewModel(coordinator: self)
        
        let goalInputSelectVC = GoalInputSelectViewController(viewModel: goalInputSelectVM, curationData: curationData)
        
        print("🟡 GoalInputSelectViewController 생성 완료")
        print("🟡 push 시작")
        navigationController.pushViewController(goalInputSelectVC, animated: true)
    }
    
    // 다음 화면으로 이동
    func showNextFlow(selectedGoalInput: String) {
        print("선택된 관심사: \(curationData.interest ?? "없음"), 작성한 목표: \(selectedGoalInput)")
        
        
        curationData.goal = selectedGoalInput
        
        
        // 온보딩 완료
        TokenStorageService.shared.saveOnboardingCompleted(true)
        print("✅온보딩 완료!! - onboardingCompleted: \(TokenStorageService.shared.isOnboardingCompleted)")
        
        
        print("📦 저장된 데이터 - 작성 목표: \(selectedGoalInput)")
        
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
        print("📦 ========================== 📦")
        
        onFinish?(curationData)
    }
}

