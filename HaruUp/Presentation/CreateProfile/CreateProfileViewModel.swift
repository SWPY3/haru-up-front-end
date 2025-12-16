//
//  CreateProfileViewModel.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit
import RxSwift
import RxCocoa


final class CreateProfileViewModel {
    // Input
    let characterSelected = BehaviorRelay<Int>(value: 0) // 선택된 캐릭터 인덱스 (0 or 1)
    let nextButtonTapped = PublishSubject<Void>()
    
    // Output
    let shouldMoveToNickname = PublishSubject<Int>() // 선택된 캐릭터 인덱스와 함께 이동
    let shouldComplete = PublishSubject<Void>()
    let showDuplicateNicknameAlert = PublishSubject<Void>()
    let errorMessage = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    private let memberAPI: MemberAPIProtocol
    private let tokenStorage: TokenStorageService
    
    
    init(
        memberAPI: MemberAPIProtocol = MemberAPI(),
        tokenStorage: TokenStorageService = .shared
    ) {
        self.memberAPI = memberAPI
        self.tokenStorage = tokenStorage
        setupBindings()
    }
    
    private func setupBindings() {
        nextButtonTapped
            .withLatestFrom(characterSelected)
            .subscribe(onNext: { [weak self] selectedCharacter in
                self?.shouldMoveToNickname.onNext(selectedCharacter)
            })
            .disposed(by: disposeBag)
    }
    
    // 닉네임 중복 체크 + 프로필 생성
    func submitProfile(characterIndex: Int, nickname: String) {
        // 디버깅
        print("=== 🙂프로필 생성 시작 ===")
        print("캐릭터 인덱스: \(characterIndex)")
        print("닉네임: \(nickname)")
        
        // ✅ 모든 저장된 값 확인
        let memberIdString = tokenStorage.getMemberId()
        let refreshToken = tokenStorage.getRefreshToken()
        let accessToken = tokenStorage.getAccessToken()
        
        print("MemberId: \(memberIdString ?? "nil")")
        print("RefreshToken: \(refreshToken != nil ? "있음 (\(refreshToken!.prefix(20))...)" : "nil")")
        print("AccessToken: \(accessToken != nil ? "있음" : "nil")")
        
        shouldComplete.onNext(())
        
        // TODO: - MemberId 확인 후 수정
        
        //        guard
        //            let memberIdStr = memberIdString,
        //            !memberIdStr.isEmpty,
        //            let memberId = Int(memberIdStr),
        //            let refreshToken = refreshToken,
        //            !refreshToken.isEmpty
        //        else {
        //            let errorMsg = "로그인 정보를 찾을 수 없습니다.\nMemberId: \(memberIdString ?? "nil")\nRefreshToken: \(refreshToken != nil ? "있음" : "nil")"
        //            print("❌ \(errorMsg)")
        //            errorMessage.onNext("로그인 정보를 찾을 수 없습니다.")
        //            return
        //        }
        //
        //        print("✅ 로그인 정보 확인 완료")
        //        print("   MemberId: \(memberId)")
        //
        //
        //        memberAPI.checkNicknameDuplicate(nickname, refreshToken: refreshToken)
        //                .do(onSubscribe: {
        //                    print("📡 닉네임 중복 체크 API 호출 중...")
        //                })
        //                .flatMap { [weak self] response -> Single<DefaultProfileResponse> in
        //                    guard let self = self else { return .never() }
        //
        //                    print("📡 닉네임 중복 체크 응답: success=\(response.success)")
        //
        //                    if !response.success {
        //                        print("❌ 닉네임 중복")
        //                        self.showDuplicateNicknameAlert.onNext(())
        //                        return .never()
        //                    }
        //
        //                    print("✅ 닉네임 사용 가능")
        //                    print("📡 default_profile API 호출 중...")
        //
        //
        //                    // TODO: - memberId 확인 후 default_profile 호출
        //
        //                    // 2) default_profile 생성
        //                    let request = DefaultProfileRequest(
        //                        id: memberId,
        //                        characterImgRef: characterIndex,
        //                        name: nickname,
        //                        description: nickname
        //                    )
        //                    return self.memberAPI.createDefaultProfile(request: request, refreshToken: refreshToken)
        //                }
        //                .subscribe(onSuccess: { [weak self] response in
        //                    print("📡 default_profile 응답: success=\(response.success)")
        //                    if response.success {
        //                        print("✅ 프로필 생성 완료")
        //                        self?.tokenStorage.saveOnboardingCompleted(true)
        //                        self?.shouldComplete.onNext(())
        //                    } else {
        //                        let errorMsg = response.message ?? "프로필 생성에 실패했습니다."
        //                        print("❌ \(errorMsg)")
        //                        self?.errorMessage.onNext(errorMsg)
        //                    }
        //                }, onFailure: { [weak self] error in
        //                    print("❌ API 호출 실패: \(error.localizedDescription)")
        //                    self?.errorMessage.onNext(error.localizedDescription)
        //                })
        //                .disposed(by: disposeBag)
        //    }
    }
}
