//
//  JobDetailSelect.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

final class JobDetailSelectViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let jobDetailSelected: Observable<JobDetail>
        let nextButtonTapped: Observable<Void>
    }
    struct Output {
        let jobDetails: Driver<[JobDetail]>
        let selectedJobDetail: Driver<JobDetail?>
        let isLoading: Driver<Bool>
    }
    
    private weak var coordinator: JobDetailSelectCoordinator?
    private let disposeBag = DisposeBag()
    private let selectedJob: Job
    
    private let jobDetailList = BehaviorRelay<[JobDetail]>(value: [])
    private let currentSelectedJobDetail = BehaviorRelay<JobDetail?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    init(coordinator: JobDetailSelectCoordinator, selectedJob: Job) {
        self.coordinator = coordinator
        self.selectedJob = selectedJob
    }
    
    func transform(input: Input) -> Output {
        
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[JobDetail]> in
                guard let self = self else { return .empty() }
                return self.fetchJobDetailList(jobId: self.selectedJob.id)
            }
            .bind(to: jobDetailList)
            .disposed(by: disposeBag)
        
        
        // 세부 직무 선택 처리
        input.jobDetailSelected
            .bind(to: currentSelectedJobDetail)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .withLatestFrom(currentSelectedJobDetail)
            .subscribe(onNext: { [weak self] selectedJobDetail in
                print("🔵 다음 버튼 탭됨")
                guard let selectedJobDetail = selectedJobDetail else {
                    print("❌ 세부 직무를 선택해주세요")
                    return
                }
                
                print("🔵 선택된 세부 직무: \(selectedJobDetail.jobDetailName), ID: \(selectedJobDetail.id)")
                self?.coordinator?.showGenderSelectFlow(selectedJobDetail: selectedJobDetail)
            })
            .disposed(by: disposeBag)
        
        return Output(
            jobDetails: jobDetailList.asDriver(),
            selectedJobDetail: currentSelectedJobDetail.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
    
    
    // MARK: - API
    
    // 세부 직업 목록 가져오기
    private func fetchJobDetailList(jobId: Int) -> Observable<[JobDetail]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 로딩 시작
            self.isLoading.accept(true)
            
            let urlString = NetworkDefine.JobAPI.getJobDetailList(jobId: jobId).url
            
            guard let refreshToken = TokenStorageService.shared.getRefreshToken() else {
                print("❌ refreshToken이 없습니다")
                self.isLoading.accept(false)
                observer.onError(NSError(domain: "AuthError", code: 401))
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "jwt-token": refreshToken
            ]
            
            // ✅ 파라미터 추가
            let parameters: [String: Int] = ["jobId": jobId]
            
            print("📡 세부 직업 목록 요청")
            print("🌐 URL: \(urlString)")
            print("🔑 jobId: \(jobId)")
            
            let request = AF.request(
                urlString,
                method: .get,
                parameters: parameters,  // ✅ 파라미터 추가
                headers: headers
            )
                .validate()
                .responseDecodable(of: [JobDetail].self) { [weak self] response in
                    self?.isLoading.accept(false)
                    
                    switch response.result {
                    case .success(let jobDetails):
                        print("✅ 세부 직업 목록 조회 성공: \(jobDetails.count)개")
                        jobDetails.forEach { print("  - \($0.jobDetailName) (ID: \($0.id))") }
                        observer.onNext(jobDetails)
                        observer.onCompleted()
                        
                    case .failure(let error):
                        print("❌ 세부 직업 목록 조회 실패: \(error.localizedDescription)")
                        
                        if let statusCode = response.response?.statusCode {
                            print("📛 HTTP Status Code: \(statusCode)")
                        }
                        
                        // 에러 발생 시 빈 배열 반환
                        observer.onNext([])
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
}
