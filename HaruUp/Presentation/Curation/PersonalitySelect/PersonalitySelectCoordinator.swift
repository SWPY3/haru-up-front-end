//
//  PersonalitySelectCoordinator.swift
//  HaruUp
//

import UIKit

/// 캐릭터 인사 이후, 챗봇 시작 전에 AI 성격을 고르는 단계.
/// 여기서 고른 성격은 큐레이션 꼬리질문의 말투에만 반영된다.
final class PersonalitySelectCoordinator: Coordinator {
    let navigationController: UINavigationController

    var childCoordinators: [any Coordinator] = []

    private var curationData: CurationData
    var onFinish: ((CurationData) -> Void)?

    init(navigationController: UINavigationController, curationData: CurationData) {
        self.navigationController = navigationController
        self.curationData = curationData
    }

    func start() {
        let viewModel = PersonalitySelectViewModel(coordinator: self, characterService: CharacterService())
        let viewController = PersonalitySelectViewController(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }

    func didSelectPersonality() {
        showCurationChatFlow()
    }

    private func showCurationChatFlow() {
        let curationChatCoordinator = CurationChatCoordinator(
            navigationController: navigationController,
            curationData: curationData
        )

        curationChatCoordinator.onFinish = { [weak self, weak curationChatCoordinator] curationData in
            if let coordinator = curationChatCoordinator,
               let index = self?.childCoordinators.firstIndex(where: { $0 === coordinator }) {
                self?.childCoordinators.remove(at: index)
            }

            self?.onFinish?(curationData)
        }

        childCoordinators.append(curationChatCoordinator)
        curationChatCoordinator.start()
    }
}
