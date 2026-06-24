//
//  AppCoordinator.swift
//  HaruUp
//
//  Created by 조영현 on 12/1/25.
//

import UIKit
import RxSwift

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let tokenStorage = TokenStorageService.shared
    private var curationData = CurationData()
    private let disposeBag = DisposeBag()
    private let chatbotService = ChatbotService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        setupPushNotificationObserver()
    }

    func start() {
        // TODO: 토큰 유무에 따라 Login 및 Home에 따라 분기 처리 - (token 서버에서 나오는 token)
        
        let splashCoordinator = SplashCoordinator(navigationController: navigationController)
        childCoordinators.append(splashCoordinator)
        
        splashCoordinator.onFinish = { [weak self, weak splashCoordinator] result in
            guard let self = self else { return }
            
            // SplashCoordinator 메모리 정리
            if let splash = splashCoordinator, let index = self.childCoordinators.firstIndex(where: { $0 === splash }) {
                self.childCoordinators.remove(at: index)
            }
            // 분기처리 구분
            switch result {
            case .needLogin:
                showLoginFlow()
            case .onboardingRequired:
                showAgreeFlow()
            case .onboardingCompleted:
                showMainTabFlow()
            }
        }
        
        splashCoordinator.start()
    }
    
    // MARK: - Push Notification Observer
    private func setupPushNotificationObserver() {
        PushNotificationService.shared.pushData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.handlePushNotification(data)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Push Notification Handler (추가)
    private func handlePushNotification(_ data: [AnyHashable: Any]) {
        print("🔔 푸시 알림 수신: \(data)")
        
        // 푸시 데이터에서 type 추출
        guard let type = data["type"] as? String else {
            print("⚠️ 푸시 타입이 없습니다")
            return
        }
        
        // 타입별 화면 이동 처리
        switch type {
        case "home":
            // 홈 화면으로 이동
            navigateToHome()
            
        default:
            print("⚠️ 알 수 없는 푸시 타입: \(type)")
        }
    }
    
    private func navigateToHome() {
        print("🏠 홈 화면으로 이동")
        
        // 이미 메인 화면이면 홈 탭으로 전환
        if let mainTabCoordinator = childCoordinators.first(where: { $0 is MainTabBarCoordinator }) as? MainTabBarCoordinator {
            mainTabCoordinator.selectHomeTab()
        } else {
            showMainTabFlow()
        }
    }
    
    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.onFinish = { [weak self, weak loginCoordinator] loginResult in
            guard let self else { return }
            
            // LoginCoordinator 메모리 정리
            if let coordinator = loginCoordinator,
               let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self.childCoordinators.remove(at: index)
            }
            // 로그인 완료 후 분기 처리 개선
            print("🔍 로그인 결과 - onboardingCompleted: \(loginResult.onboardingCompleted)")
            
            // 로그인 완료 후 온보딩 여부 확인
            if loginResult.onboardingCompleted {
                print("✅ 온보딩 완료 → 홈 화면으로 이동")
                self.showMainTabFlow()
            } else {
                print("⚠️ 온보딩 필요 → 온보딩 전 동의화면으로 이동")
                self.showAgreeFlow()
            }
        }
        
        loginCoordinator.gotoHome = { [weak self] in
            guard let self else { return }
            
            self.showMainTabFlow()
        }
        
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    private func showAgreeFlow() {
        let agreeCoordinator = AgreeCoordinator(navigationController: navigationController)
        
        agreeCoordinator.onFinish = { [weak self, weak agreeCoordinator] in
            guard let self = self else { return }
            
            if let coordinator = agreeCoordinator,
               let index = self.childCoordinators.firstIndex(where: {$0 === coordinator}) {
                self.childCoordinators.remove(at: index)
            }
            
            self.showOnboardingFlow()
        }
        
        agreeCoordinator.onBack = { [weak self, weak agreeCoordinator] in
            guard let self = self else { return }
            
            // 1. AgreeCoordinator 정리
            if let coordinator = agreeCoordinator,
               let index = self.childCoordinators.firstIndex(where: {$0 === coordinator}) {
                self.childCoordinators.remove(at: index)
            }
            
            // 2. 현재 화면(약관동의)을 pop 하고
            self.navigationController.popViewController(animated: true)
            
            // 3. 로그인 플로우 다시 시작
            self.showLoginFlow()
        }
        
        childCoordinators.append(agreeCoordinator)
        agreeCoordinator.start()
    }
    
    private func showOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        
        onboardingCoordinator.onFinish = { [weak self, weak onboardingCoordinator] in
            guard let self = self else { return }
            
            if let coordinator = onboardingCoordinator,
               let index = self.childCoordinators.firstIndex(where: {$0 === coordinator}) {
                self.childCoordinators.remove(at: index)
            }
            
            self.showCurationFlow()
        }
        
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func showCurationFlow() {
        let characterSelectCoordinator = CharacterSelectCoordinator(navigationController: navigationController,
                                                                    curationData: curationData)
        
        characterSelectCoordinator.onFinish = { [weak self, weak characterSelectCoordinator] curationData in
            guard let self = self else { return }

            self.tokenStorage.saveCurationData(curationData)
            self.tokenStorage.saveOnboardingCompleted(true)

            if let coordinator = characterSelectCoordinator,
               let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self.childCoordinators.remove(at: index)
            }

            // 캐릭터 ID와 닉네임만 서버에 등록 (챗봇 플로우: 관심사/직업 불필요)
            guard let characterId = curationData.characterId,
                  let nickname = curationData.nickname else {
                self.showMainTabFlow()
                return
            }

            let missions = curationData.chatbotMissions ?? []
            UserDefaultsManager.shared.selectedMemberInterestId = nil
            UserDefaultsManager.shared.usesChatbotGoalMissions = true

            self.chatbotService.chatbotSetup(characterId: characterId, nickname: nickname)
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onSuccess: { [weak self] _ in
                        self?.showMissionSelectionFlow(missions: missions)
                    },
                    onFailure: { [weak self] _ in
                        // API 실패해도 미션 선택 화면으로 이동 (캐릭터는 서버에서 멱등 처리)
                        self?.showMissionSelectionFlow(missions: missions)
                    }
                )
                .disposed(by: self.disposeBag)
        }
        
        childCoordinators.append(characterSelectCoordinator)
        characterSelectCoordinator.start()
    }
    
    
    private func showMissionSelectionFlow(missions: [ChatbotMissionDto]) {
        let missionCoordinator = TodayMissionCoordinator(
            navigationController: navigationController,
            missionService: MissionService(),
            interestsService: InterestsService.shared,
            chatbotMissions: missions
        )

        missionCoordinator.onFinish = { [weak self, weak missionCoordinator] in
            if let coordinator = missionCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }
            self?.showMainTabFlow()
        }

        childCoordinators.append(missionCoordinator)
        missionCoordinator.start()
    }

    private func showMainTabFlow() {
        let mainTabCoordinator = MainTabBarCoordinator(navigationController: navigationController, curationData: curationData, appCoordinator: self)
        childCoordinators.append(mainTabCoordinator)
        
        mainTabCoordinator.start()
    }
}
