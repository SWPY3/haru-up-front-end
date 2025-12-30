//
//  MyPageViewModel.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        // 버튼 5개에 대한 이벤트
        let editInterestTapped: ControlEvent<Void>
        let feedbackTapped: ControlEvent<Void>   // 피드백하기
        let inquiryTapped: ControlEvent<Void>    // 문의하기
        let logoutTapped: ControlEvent<Void>
        let withdrawTapped: ControlEvent<Void>
    }
    
    struct Output {
        let curationData: Driver<CurationData>
        let appVersion: Driver<String>
    }
    
    private let curationData: CurationData
    
    init(curationData: CurationData) {
        self.curationData = curationData
    }
    
    func transform(input: Input) -> Output {
        let curationDataDriver = input.viewDidLoad
            .map { [weak self] _ in self?.curationData }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
        
        let version = Driver.just("버전.v.16.2")
        
        return Output(
            curationData: curationDataDriver,
            appVersion: version
        )
    }
}
