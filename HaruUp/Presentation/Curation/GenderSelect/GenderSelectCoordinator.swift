//
//  GenderSelectCoordinator.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit


final class GenderSelectCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    var childCoordinators: [any Coordinator] = []
    
    private var curationData: CurationData
    
    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }
    
    
    func start() {
        let genderSelectVM = GenderSelectViewModel(coordinator: self)
        let genderSelectVC = GenderSelectViewController(viewModel: genderSelectVM)
        navigationController.pushViewController(genderSelectVC, animated: true)
    }
    
    func showNextFlow(selectedGender: String) {
        print("선택된 성별\(selectedGender)")
        
        curationData.gender = selectedGender
        print("📦 저장된 데이터 - 성별: \(selectedGender)")
        print("📦 ===== 최종 수집된 데이터 =====")
                print("캐릭터 ID: \(curationData.characterId ?? -1)")
                print("닉네임: \(curationData.nickname ?? "없음")")
                print("직업: \(curationData.job ?? "없음")")
                print("세부 직무: \(curationData.jobDetail ?? "없음")")
                print("성별: \(curationData.gender ?? "없음")")
                print("📦 ===============================")
        
    }
}
