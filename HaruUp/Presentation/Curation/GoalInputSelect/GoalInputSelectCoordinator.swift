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
        let goalInputSelectVM = GoalInputSelectViewModel(coordinator: self, curationData: curationData)
        
        let goalInputSelectVC = GoalInputSelectViewController(viewModel: goalInputSelectVM, curationData: curationData)
        
        print("🟡 GoalInputSelectViewController 생성 완료")
        print("🟡 push 시작")
        navigationController.pushViewController(goalInputSelectVC, animated: true)
    }
    
    // 다음 화면으로 이동
    func showNextFlow(selectedGoalInput: InterestData) {
        curationData.goal = selectedGoalInput
        onFinish?(curationData)
    }
}

