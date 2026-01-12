//
//  ChartViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import RxSwift
import RxCocoa
import Foundation

final class ChartViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let filterApplied: Observable<[String]>
    }
    
    // MARK: - Output
    struct Output {
        let hasData: Driver<Bool>
        let rankingData: Driver<[ChartItem]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let service = ChartService()
    
    // 데이터 흐름을 관리하는 Relay
    private let rankingDataRelay = BehaviorRelay<[ChartItem]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    // MARK: - Filter Mapping Data
    // UI에서 선택한 한글 태그를 서버 API 파라미터(영어/ID)로 변환하기 위한 맵
    private let genderMap = ["남성": "MALE", "여성": "FEMALE"]
    
    private let ageMap = [
        "19세 이하": "UNDER_19",
        "20 - 24세": "MID_20S",
        "25 - 29세": "LATE_20S",
        "30 - 34세": "EARLY_30S",
        "35 - 39세": "LATE_30S",
        "40세 이상": "FORTIES"
    ]
    
    private let jobMap = ["직장인": 1, "자영업": 2, "학생": 3, "취준생": 4]
    // TODO: - 세부 직업 Id, 관심사 id 다 불러오기
    private let jobDetailMap: [String: Int] = [
        "디자이너": 1,
        "기획자": 2,
        "개발자": 3,
        "사무직": 4,
        "서비스직": 5,
        "교육 종사자": 6,
        "의료직": 7,
        "공공·복지": 8,
        "예체능": 9
    ]
    
    private let interestKeywords = ["외국어 공부", "자격증 공부", "재테크/투자", "체력관리 및 운동", "직무 관련 역량 개발"]
    
    init() {
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // 화면 진입 시
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.fetchRanking(tags: [])
            })
            .disposed(by: disposeBag)
        
        // 필터 적용 시 (선택된 태그로 조회)
        input.filterApplied
            .subscribe(onNext: { [weak self] tags in
                self?.fetchRanking(tags: tags)
            })
            .disposed(by: disposeBag)
        
        // hasData: 데이터가 있는지 여부
        let hasData = rankingDataRelay
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        let rankingData = rankingDataRelay.asDriver(onErrorJustReturn: [])
        let isLoading = isLoadingRelay.asDriver(onErrorJustReturn: false)
        let error = errorRelay.asDriver(onErrorJustReturn: "")
        
        return Output(
            hasData: hasData,
            rankingData: rankingData,
            isLoading: isLoading,
            error: error
        )
    }
    
    // MARK: - API Methods
    private func fetchRanking(tags: [String]) {
        // 로딩 시작
        isLoadingRelay.accept(true)
        
        // 1. UI 태그를 API 파라미터로 변환
        let parameters = convertTagsToParameters(tags: tags)
        
        // 2. Service를 통해 API 호출
        service.fetchPopularRanking(parameters: parameters)
            .subscribe(onNext: { [weak self] items in
                // 성공 시 데이터 업데이트
                self?.isLoadingRelay.accept(false)
                self?.rankingDataRelay.accept(items)
                
            }, onError: { [weak self] error in
                // 실패 시 에러 처리
                self?.isLoadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
                print("Ranking Fetch Error: \(error)")
                
                // 에러 발생 시 기존 데이터를 비울지, 유지할지는 기획에 따라 결정 (여기선 유지)
                // self?.rankingDataRelay.accept([])
            })
            .disposed(by: disposeBag)
    }
    
    // 한글 태그 배열 -> API 파라미터 딕셔너리 변환 로직
    private func convertTagsToParameters(tags: [String]) -> [String: Any]? {
        var params: [String: Any] = [:]
        
        params["limit"] = 5
        
        var genderValue: String?
        var ageGroups: [String] = []
        var jobIds: [Int] = []
        var jobDetailIds: [Int] = []
        var interests: [String] = []
        
        for tag in tags {
            if let gender = genderMap[tag] {
                genderValue = gender
            } else if let age = ageMap[tag] {
                ageGroups.append(age)
            } else if let jobId = jobMap[tag] {
                jobIds.append(jobId)
            } else if let detailId = jobDetailMap[tag] {
                jobDetailIds.append(detailId)
            } else if interestKeywords.contains(tag) {
                interests.append(tag)
            }
        }
        
        // API 스펙에 맞춰 딕셔너리에 담기
        if let g = genderValue { params["gender"] = g }
        if !ageGroups.isEmpty { params["ageGroups"] = ageGroups }
        if !jobIds.isEmpty { params["jobIds"] = jobIds }
        if !jobDetailIds.isEmpty { params["jobDetailIds"] = jobDetailIds }
        if !interests.isEmpty { params["interests"] = interests }
        
        return params
    }
}
