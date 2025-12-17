//
//  InterestDetailSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class InterestDetailSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    private let selectedInterest: String
    
    init(navigationController: UINavigationController, selectedInterest: String, curationData: CurationData) {
        self.navigationController = navigationController
        self.selectedInterest = selectedInterest
        self.curationData = curationData
    }
    
    func start() {
        print("🟡 InterestDetailCoordinator start() 호출됨")
        print("🟡 선택된 관심사: \(selectedInterest)")
        let interestDetailSelectVM = InterestDetailSelectViewModel(
            coordinator: self,
            selectedInterest: selectedInterest
        )
        
        let interestDetailSelectVC = InterestDetailSelectViewController(viewModel: interestDetailSelectVM)
        
        print("🟡 InterestDetailSelectViewController 생성 완료")
        print("🟡 push 시작")
        navigationController.pushViewController(interestDetailSelectVC, animated: true)
    }
    
    // 다음 화면으로 이동
    func showNextFlow(selectedInterestDetail: String) {
        print("선택된 관심사: \(selectedInterest), 선택된 세부 직무: \(selectedInterestDetail)")
        
        
        curationData.interestDetail = selectedInterestDetail
        print("📦 저장된 데이터 - 상세직업: \(selectedInterestDetail)")
        
    }
}
