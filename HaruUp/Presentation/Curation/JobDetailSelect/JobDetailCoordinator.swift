//
//  JobDetailCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit


final class JobDetailSelectCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    private let selectedJob: String
    
    init(navigationController: UINavigationController, selectedJob: String, curationData: CurationData) {
        self.navigationController = navigationController
        self.selectedJob = selectedJob
        self.curationData = curationData
    }
    
    func start() {
        print("🟡 JobDetailSelectCoordinator start() 호출됨")
        print("🟡 선택된 직업: \(selectedJob)")
        let jobDetailSelectVM = JobDetailSelectViewModel(
            coordinator: self,
            selectedJob: selectedJob
        )
        let jobDetailSelectVC = JobDetailSelectViewController(viewModel: jobDetailSelectVM)
        
        print("🟡 JobDetailSelectViewController 생성 완료")
        print("🟡 push 시작")
        navigationController.pushViewController(jobDetailSelectVC, animated: true)
    }
    
    // 다음 화면으로 이동
    func showGenderSelectFlow(selectedJobDetail: String) {
        print("선택된 직업: \(selectedJob), 선택된 세부 직무: \(selectedJobDetail)")
        let genderSelectCoordinator = GenderSelectCoordinator(
            navigationController: navigationController,
            curationData: curationData)
        
        curationData.jobDetail = selectedJobDetail
        print("📦 저장된 데이터 - 상세직업: \(selectedJobDetail)")
        childCoordinators.append(genderSelectCoordinator)
        
        genderSelectCoordinator.start()
    }
}
