//
//  ChartViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

final class ChartViewModel {
    // 차트 데이터가 있는지 여부를 판단하는 플래그
    var hasData: Bool {
        return !rankingData.isEmpty
    }
    
    let rankingData: [ChartItem] = [
        ChartItem(rank: 1, title: "디자인 트렌드 찾아 정리하기", tags: ["직무 관련 역량 개발", "업무 능력 향상"], count: 150),
        ChartItem(rank: 2, title: "포트폴리오용 프로젝트 정리하기", tags: ["직무 관련 역량 개발", "이직 준비"], count: 98),
        ChartItem(rank: 3, title: "영국 뉴스 기사 읽기", tags: ["외국어 공부", "영어"], count: 80),
        ChartItem(rank: 4, title: "물 마시기", tags: ["체력관리 및 운동", "AI 사용 역량 강화"], count: 75),
        ChartItem(rank: 5, title: "AI로 모션 영상 만들기", tags: ["직무 관련 역량 개발", "AI 사용 역량 강화"], count: 58)
    ]
}
