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
    private let selectedInterest: Interest
    
    var onFinish: ((CurationData) -> Void)?
    
    init(navigationController: UINavigationController, selectedInterest: Interest, curationData: CurationData) {
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
    
    func showForeignLanguageInput(id: Int) {
        print("🔵 외국어 입력 모달 표시")
        
        let vm = ForeignLanguageInputBottomSheetViewModel()
        
        let bottomSheet = ForeignLanguageInputBottomSheet(
            viewModel: vm,
            type: .curation
        )
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        
        bottomSheet.onFinish = { [weak self] foreignLanguage in
            print("✅ 입력된 외국어: \(foreignLanguage)")
            // 입력된 외국어를 다음 화면으로 전달
            let customInterestData = InterestData(id: id, name: foreignLanguage)
            let customInterestDetail = InterestDetail(id: id, name: foreignLanguage)
            
            self?.curationData.interestDetail = customInterestData
            self?.showGoalSelectFlow(selectedInterestDetail: customInterestDetail)
        }
        
        // navigationController의 최상단 ViewController에서 present
        navigationController.topViewController?.present(bottomSheet, animated: true)
    }
    
    // 다음 화면으로 이동
    func showGoalSelectFlow(selectedInterestDetail: InterestDetail) {
        print("선택된 관심사: \(selectedInterest), 선택된 세부 직무: \(selectedInterestDetail)")
        
        let interestData = InterestData(id: selectedInterestDetail.id, name: selectedInterestDetail.name)
        
        curationData.interestDetail = interestData
        print("📦 저장된 데이터 - 세부 관심사: \(selectedInterestDetail.name), ID: \(selectedInterestDetail.id)")
        
        let goalSelectCoordinator = GoalSelectCoordinator(navigationController: navigationController, selectedInterestDetail: selectedInterestDetail, curationData: curationData)
        
        goalSelectCoordinator.onFinish = { [weak self, weak goalSelectCoordinator] curationData in
            if let coordinator = goalSelectCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            
            self?.onFinish?(curationData)
        }
        
        childCoordinators.append(goalSelectCoordinator)
        goalSelectCoordinator.start()
        
    }
}
