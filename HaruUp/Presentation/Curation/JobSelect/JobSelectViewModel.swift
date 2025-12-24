//
//  JobSelectViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire


final class JobSelectViewModel {
    // Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let jobSelected: Observable<Job>
        let nextButtonTapped: Observable<Void>
    }
    
    // Output
    struct Output {
        let jobs: Driver<[Job]>
        let selectedJob: Driver<Job?>
        let isLoading: Driver<Bool>
    }
    
    private weak var coordinator: JobSelectCoordinator?
    private let disposeBag = DisposeBag()
    
    // 직업 목록
    private let jobList = BehaviorRelay<[Job]>(value: [])
    private let currentSelectedJob = BehaviorRelay<Job?>(value: nil)
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    
    init(coordinator: JobSelectCoordinator) {
        self.coordinator = coordinator
        print("🔴 JobSelectViewModel init - coordinator: \(coordinator)")
    }
    
    func transform(input: Input) -> Output {
        
        // 화면 로드 시 직업 목롤 호출
        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[Job]> in
                guard let self = self else { return .empty() }
                return self.fetchJobList()
            }
            .bind(to: jobList)
            .disposed(by: disposeBag)
        
        // 직업 선택
        input.jobSelected
            .bind(to: currentSelectedJob)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withLatestFrom(currentSelectedJob)
            .subscribe(onNext: { [weak self] selectedJob in
                print("🔵 다음 버튼 탭됨")
                guard let selectedJob = selectedJob else {
                    print("직업을 선택해주세요.")
                    return
                }
                
                print("🔵 선택된 직업: \(selectedJob.jobName), id: \(selectedJob.id)")
                print("🔵 Coordinator 호출 시작")
                self?.coordinator?.showjobDetailFlow(selectedJob: selectedJob)
            })
            .disposed(by: disposeBag)
        
        return Output(
            jobs: jobList.asDriver(),
            selectedJob: currentSelectedJob.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
    
    
    // MARK: - API
    private func fetchJobList() -> Observable<[Job]> {
        return Observable.create { [ weak self ] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 로딩 시작
            self.isLoading.accept(true)
            
            let urlString = NetworkDefine.JobAPI.getJobList.url
            
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
            
            print("📡 직업 목록 요청")
            print("🌐 URL: \(urlString)")
            
            let request = AF.request(
                urlString,
                method: .get,
                headers: headers
            )
            .validate()
            .responseDecodable(of: [Job].self) { [weak self] response in
                self?.isLoading.accept(false)
                
                switch response.result {
                case .success(let jobs):
                    print("✅ 직업 목록 조회 성공: \(jobs.count)개")
                    jobs.forEach { print("  - \($0.jobName) (ID: \($0.id))") }
                    observer.onNext(jobs)
                    observer.onCompleted()
                    
                case .failure(let error):
                    print("❌ 직업 목록 조회 실패: \(error.localizedDescription)")
                    
                    if let statusCode = response.response?.statusCode {
                        print("📛 HTTP Status Code: \(statusCode)")
                    }
                    
                    // 에러 발생 시 빈 배열 반환 (화면은 유지)
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
