//
//  ChartViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import RxSwift
import RxCocoa

final class ChartViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let filterApplied: Observable<[String]>
    }
    
    // MARK: - Output
    struct Output {
        let hasData: Driver<Bool>
        let rankingData: Driver<[ChartItem]>
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // 실제 데이터를 관리하는 BehaviorRelay
    private let rankingDataRelay = BehaviorRelay<[ChartItem]>(value: [])
    
    init() {
        // 초기 데이터 설정 (실제로는 API 호출 등으로 가져올 수 있음)
        loadInitialData()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // viewDidLoad 시 데이터 로드 (필요시)
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.loadInitialData()
            })
            .disposed(by: disposeBag)
        
        // 필터 적용 시 데이터 필터링
        input.filterApplied
            .subscribe(onNext: { [weak self] tags in
                self?.filterData(by: tags)
            })
            .disposed(by: disposeBag)
        
        // hasData: 데이터가 있는지 여부
        let hasData = rankingDataRelay
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        // rankingData: 실제 랭킹 데이터
        let rankingData = rankingDataRelay
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            hasData: hasData,
            rankingData: rankingData
        )
    }
    
    // MARK: - Private Methods
    private func loadInitialData() {
        // 실제 데이터 (API 호출 등으로 대체 가능)
        let data: [ChartItem] = [
            ChartItem(rank: 1, title: "디자인 트렌드 찾아 정리하기", tags: ["직무 관련 역량 개발", "업무 능력 향상"], count: 150),
            ChartItem(rank: 2, title: "포트폴리오용 프로젝트 정리하기", tags: ["직무 관련 역량 개발", "이직 준비"], count: 98),
            ChartItem(rank: 3, title: "영국 뉴스 기사 읽기", tags: ["외국어 공부", "영어"], count: 80),
            ChartItem(rank: 4, title: "물 마시기", tags: ["체력관리 및 운동", "AI 사용 역량 강화"], count: 75),
            ChartItem(rank: 5, title: "AI로 모션 영상 만들기", tags: ["직무 관련 역량 개발", "AI 사용 역량 강화"], count: 58)
        ]
        
        rankingDataRelay.accept(data)
        
        // 테스트용: 데이터가 없는 경우
        // rankingDataRelay.accept([])
    }
    
    private func filterData(by tags: [String]) {
        // 필터링 로직 구현
        // 실제로는 API 재호출 또는 로컬 필터링
        if tags.isEmpty {
            loadInitialData()
        } else {
            // 태그에 맞는 데이터만 필터링하는 로직
            // 예시: 실제 구현 필요
            let filtered = rankingDataRelay.value.filter { item in
                tags.contains(where: { item.tags.contains($0) })
            }
            rankingDataRelay.accept(filtered)
        }
    }
}
