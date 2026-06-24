//
//  TodayMissionListViewModelTests.swift
//  HaruUpTests
//
//  Created by Codex on 6/24/26.
//

import XCTest
import RxSwift
@testable import HaruUp

final class TodayMissionListViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        resetMissionSourceDefaults()
    }

    override func tearDown() {
        resetMissionSourceDefaults()
        disposeBag = nil
        super.tearDown()
    }

    func test_chatbotCompletionMissionsAreShownWithoutRecommendRequest() {
        let missionService = MissionServiceSpy()
        let viewModel = makeViewModel(
            missionService: missionService,
            chatbotMissions: [makeChatbotMission(id: 101)]
        )
        let input = makeInput()
        var observedMissionIDs: [[Int]] = []

        viewModel.transform(input: input.value)
            .missions
            .subscribe(onNext: { missions in
                observedMissionIDs.append(missions.map(\.memberMissionId))
            })
            .disposed(by: disposeBag)

        input.viewDidLoad.onNext(())

        XCTAssertEqual(observedMissionIDs.last, [101])
        XCTAssertTrue(missionService.singleRecommendRequests.isEmpty)
        XCTAssertTrue(missionService.recommendMultipleRequests.isEmpty)
    }

    func test_emptyChatbotCompletionMissionsShowEmptyStateWithoutRecommendRequest() {
        let missionService = MissionServiceSpy()
        let viewModel = makeViewModel(
            missionService: missionService,
            chatbotMissions: []
        )
        let input = makeInput()
        var observedMissionIDs: [[Int]] = []

        viewModel.transform(input: input.value)
            .missions
            .subscribe(onNext: { missions in
                observedMissionIDs.append(missions.map(\.memberMissionId))
            })
            .disposed(by: disposeBag)

        input.viewDidLoad.onNext(())

        XCTAssertEqual(observedMissionIDs.last, [])
        XCTAssertTrue(missionService.singleRecommendRequests.isEmpty)
        XCTAssertTrue(missionService.recommendMultipleRequests.isEmpty)
    }

    func test_chatbotRequeryRequestsRecommendWithOnlyChatbotGoalInterestId() {
        UserDefaultsManager.shared.usesChatbotGoalMissions = true
        let missionService = MissionServiceSpy()
        missionService.recommendMultipleMissionIDs = [201, 202]
        let viewModel = makeViewModel(missionService: missionService)
        let input = makeInput()
        var observedMissionIDs: [[Int]] = []

        viewModel.transform(input: input.value)
            .missions
            .subscribe(onNext: { missions in
                observedMissionIDs.append(missions.map(\.memberMissionId))
            })
            .disposed(by: disposeBag)

        input.viewDidLoad.onNext(())

        XCTAssertEqual(missionService.recommendMultipleRequests, [[MissionSource.chatbotGoalInterestId]])
        XCTAssertTrue(missionService.singleRecommendRequests.isEmpty)
        XCTAssertEqual(observedMissionIDs.last, [201, 202])
    }

    func test_chatbotRetryRequestsGoalInterestIdAndOmitsExcludedMissionIds() {
        let missionService = MissionServiceSpy()
        let viewModel = makeViewModel(
            missionService: missionService,
            chatbotMissions: [makeChatbotMission(id: 301)]
        )
        let input = makeInput()

        viewModel.transform(input: input.value)
            .missions
            .subscribe()
            .disposed(by: disposeBag)

        input.viewDidLoad.onNext(())
        input.missionSelected.onNext(301)
        input.retryRecommend.onNext(())

        XCTAssertEqual(missionService.retryRequests.map(\.memberInterestId), [MissionSource.chatbotGoalInterestId])
        XCTAssertNil(missionService.retryRequests.first?.excludeMissionIDs)
    }

    func test_interestRequeryUsesRealInterestIdWithoutMixingChatbotGoalId() {
        UserDefaultsManager.shared.selectedMemberInterestId = 42
        let missionService = MissionServiceSpy()
        missionService.recommendMultipleMissionIDs = [401]
        let viewModel = makeViewModel(missionService: missionService)
        let input = makeInput()

        viewModel.transform(input: input.value)
            .missions
            .subscribe()
            .disposed(by: disposeBag)

        input.viewDidLoad.onNext(())

        XCTAssertEqual(missionService.recommendMultipleRequests, [[42]])
        XCTAssertFalse(missionService.recommendMultipleRequests.contains([MissionSource.chatbotGoalInterestId, 42]))
        XCTAssertTrue(missionService.singleRecommendRequests.isEmpty)
    }

    func test_interestRetryKeepsRealInterestIdAndSendsSelectedMissionIdsAsExcludeList() {
        UserDefaultsManager.shared.selectedMemberInterestId = 42
        let missionService = MissionServiceSpy()
        missionService.recommendMultipleMissionIDs = [501]
        let viewModel = makeViewModel(missionService: missionService)
        let input = makeInput()

        viewModel.transform(input: input.value)
            .missions
            .subscribe()
            .disposed(by: disposeBag)

        input.viewDidLoad.onNext(())
        input.missionSelected.onNext(501)
        input.retryRecommend.onNext(())

        XCTAssertEqual(missionService.retryRequests.map(\.memberInterestId), [42])
        XCTAssertEqual(missionService.retryRequests.first?.excludeMissionIDs, [501])
    }
}

private extension TodayMissionListViewModelTests {
    typealias InputSubjects = (
        viewDidLoad: PublishSubject<Void>,
        refreshTap: PublishSubject<Void>,
        completeTap: PublishSubject<Void>,
        missionSelected: PublishSubject<Int>,
        retryRecommend: PublishSubject<Void>,
        value: TodayMissionListViewModel.Input
    )

    func makeInput() -> InputSubjects {
        let viewDidLoad = PublishSubject<Void>()
        let refreshTap = PublishSubject<Void>()
        let completeTap = PublishSubject<Void>()
        let missionSelected = PublishSubject<Int>()
        let retryRecommend = PublishSubject<Void>()

        return (
            viewDidLoad: viewDidLoad,
            refreshTap: refreshTap,
            completeTap: completeTap,
            missionSelected: missionSelected,
            retryRecommend: retryRecommend,
            value: TodayMissionListViewModel.Input(
                viewDidLoad: viewDidLoad.asObservable(),
                refreshTap: refreshTap.asObservable(),
                completeTap: completeTap.asObservable(),
                missionSelected: missionSelected.asObservable(),
                retryRecommend: retryRecommend.asObservable()
            )
        )
    }

    func makeViewModel(
        missionService: MissionServiceSpy,
        chatbotMissions: [ChatbotMissionDto]? = nil
    ) -> TodayMissionListViewModel {
        TodayMissionListViewModel(
            missionService: missionService,
            interestsService: InterestsService(),
            chatbotMissions: chatbotMissions
        )
    }

    func makeChatbotMission(id: Int) -> ChatbotMissionDto {
        ChatbotMissionDto(
            id: id,
            missionContent: "챗봇 미션 \(id)",
            missionDescription: "설명 \(id)",
            difficulty: 2,
            expEarned: 10
        )
    }

    func resetMissionSourceDefaults() {
        UserDefaultsManager.shared.selectedMemberInterestId = nil
        UserDefaultsManager.shared.usesChatbotGoalMissions = false
    }
}

private final class MissionServiceSpy: MissionServiceProtocol {
    struct RetryRequest {
        let memberInterestId: Int
        let excludeMissionIDs: [Int]?
    }

    var singleRecommendRequests: [Int] = []
    var recommendMultipleRequests: [[Int]] = []
    var retryRequests: [RetryRequest] = []

    var recommendMultipleMissionIDs: [Int] = []
    var retryMissionIDs: [Int] = [901, 902, 903, 904, 905]

    func requestRecommendedMissions(memberInterestId: Int) -> Single<MemberMission.MissionRecommendResponseDTO> {
        singleRecommendRequests.append(memberInterestId)
        return .just(MemberMission.MissionRecommendResponseDTO(
            success: true,
            data: MemberMission.MissionsDTO(missions: [], retryCount: 0),
            errorMessage: nil
        ))
    }

    func requestRecommendedMultipleMissions(memberInterestIds: [Int]) -> Single<MemberMission.RecommendMultipleResponseDTO> {
        recommendMultipleRequests.append(memberInterestIds)
        let responseGroups = memberInterestIds.map { memberInterestId in
            MemberMission.MultipleMissionsDTO(
                memberInterestId: memberInterestId,
                data: recommendMultipleMissionIDs.map { makeMultipleMission(id: $0) }
            )
        }

        return .just(MemberMission.RecommendMultipleResponseDTO(
            success: true,
            data: MemberMission.MultipleDataDTO(
                missions: responseGroups,
                totalCount: recommendMultipleMissionIDs.count,
                retryCount: 0
            ),
            errorMessage: nil
        ))
    }

    func retryRecommendMissions(memberInterestId: Int, excludeMissionIDs: [Int]?) -> Single<MemberMission.RetryRecommendResponseDTO> {
        retryRequests.append(RetryRequest(memberInterestId: memberInterestId, excludeMissionIDs: excludeMissionIDs))
        return .just(MemberMission.RetryRecommendResponseDTO(
            success: true,
            data: MemberMission.RetryMissionsDTO(
                missions: [
                    MemberMission.RetryMissionsResponseDTO(
                        memberInterestId: memberInterestId,
                        data: retryMissionIDs.map { makeRetryMission(id: $0) }
                    )
                ],
                totalCount: retryMissionIDs.count,
                retryCount: 1
            ),
            errorMessage: nil
        ))
    }

    func selectMissions(missionIDs: [Int]) -> Single<MemberMission.SelectMissionResponseDTO> {
        .just(MemberMission.SelectMissionResponseDTO(success: true, data: missionIDs, errorMessage: nil))
    }

    func fetchMissionList(
        memberInterestId: Int?,
        targetDate: String,
        status: [MemberMission.MissionStatusType]
    ) -> Single<MemberMission.FetchMissionResponseDTO> {
        .just(MemberMission.FetchMissionResponseDTO(success: true, data: [], errorMessage: nil))
    }

    func setMissionStatus(id: Int, status: String) -> Single<MemberMission.MissionStatusResponseDTO> {
        .just(MemberMission.MissionStatusResponseDTO(success: true, data: status, errorMessage: nil))
    }

    func fetchChallengeDate() -> Single<MemberMission.ChallengeResponseDTO> {
        .just(MemberMission.ChallengeResponseDTO(success: true, data: [], errorMessage: nil))
    }

    func fetchMonthlyMissions(targetMonth: String) -> Single<MemberMission.HistoryResponseDTO> {
        .just(MemberMission.HistoryResponseDTO(
            success: true,
            data: MemberMission.HistoryDTO(missionCounts: [], totalMissionCount: 0, totalCompletedDays: 0),
            errorMessage: nil
        ))
    }

    func fetchGrowthChart() -> Single<MemberMission.GrowthResponseDTO> {
        .just(MemberMission.GrowthResponseDTO(
            success: true,
            data: MemberMission.GrowthDataDTO(monthlyData: []),
            errorMessage: nil
        ))
    }

    private func makeMultipleMission(id: Int) -> MemberMission.MultipleMissionDTO {
        MemberMission.MultipleMissionDTO(
            memberMissionId: id,
            content: "추천 미션 \(id)",
            directFullPath: [],
            difficulty: 2,
            expEarned: 10,
            createdType: "AI"
        )
    }

    private func makeRetryMission(id: Int) -> MemberMission.RetryMissionDTO {
        MemberMission.RetryMissionDTO(
            memberMissionId: id,
            content: "재추천 미션 \(id)",
            directFullPath: [],
            difficulty: 2,
            expEarned: 10,
            createdType: "AI"
        )
    }
}
