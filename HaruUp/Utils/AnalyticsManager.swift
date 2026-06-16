//
//  AnalyticsManager.swift
//  HaruUp
//
//  Created by 조영현 on 2/20/26.
//

import Foundation
import AmplitudeSwift

enum AppEvent {

    // MARK: - 로그인 화면 (Login)
    enum Login: String {
        case kakaoLoginTapped = "[Login] Kakao Login Tapped"    // 카카오 로그인 버튼
        case naverLoginTapped = "[Login] Naver Login Tapped"    // 네이버 로그인 버튼
        case appleLoginTapped = "[Login] Apple Login Tapped"    // Apple 로그인 버튼
    }

    // MARK: - 이용약관 화면 (Agree)
    enum Agree: String {
        case backTapped = "[Agree] Back Tapped"                 // 뒤로가기 버튼
        case allCheckTapped = "[Agree] All Check Tapped"        // 모두 동의합니다
        case term1CheckTapped = "[Agree] Term1 Check Tapped"    // [필수] 서비스 이용약관 체크
        case term2CheckTapped = "[Agree] Term2 Check Tapped"    // [필수] 개인정보 수집 체크
        case term3CheckTapped = "[Agree] Term3 Check Tapped"    // [필수] 만 14세 이상 체크
        case term1DetailTapped = "[Agree] Term1 Detail Tapped"  // 서비스 이용약관 상세보기
        case term2DetailTapped = "[Agree] Term2 Detail Tapped"  // 개인정보 수집 상세보기
        case confirmTapped = "[Agree] Confirm Tapped"           // 동의하기 버튼
    }

    // MARK: - 온보딩 화면 (Onboarding)
    enum Onboarding: String {
        case nextTapped = "[Onboarding] Next Tapped"            // 다음 버튼 (property: page)
        case skipTapped = "[Onboarding] Skip Tapped"            // 건너뛰기 버튼
        case swipePage = "[Onboarding] Swipe Page"              // 스와이프 페이지 전환 (property: page)
        case complete = "[Onboarding] Complete"                 // 온보딩 완료
    }

    // MARK: - 캐릭터 선택 화면 (CharacterSelect)
    enum CharacterSelect: String {
        case leftArrowTapped = "[CharacterSelect] Left Arrow Tapped"        // 왼쪽 화살표 버튼
        case rightArrowTapped = "[CharacterSelect] Right Arrow Tapped"      // 오른쪽 화살표 버튼
        case characterImageTapped = "[CharacterSelect] Character Image Tapped" // 캐릭터 이미지 탭
        case nextTapped = "[CharacterSelect] Next Tapped"                   // 다음 버튼 (property: character)
    }

    // MARK: - 챗봇 입력 화면 (CurationChat)
    enum CurationChat: String {
        case closeTapped = "[CurationChat] Close Tapped"                    // X 닫기 버튼
        case messageSent = "[CurationChat] Message Sent"                    // 답변 전송
        case suggestionChipTapped = "[CurationChat] Suggestion Chip Tapped" // 추천 칩 탭 (property: chip)
        case exitConfirmTapped = "[CurationChat] Exit Confirm Tapped"       // 종료 모달 - 처음부터 다시
        case chatCompleted = "[CurationChat] Chat Completed"                // 챗봇 대화 완료
    }

    // MARK: - 미션 시작 화면 (Mission Start)
    enum MissionStart: String {
        case startTapped = "[MissionStart] Start Recommendation Tapped" // 미션 추천 시작 버튼
    }
    
    // MARK: - 미션 추천 목록 화면 (Mission List)
    enum MissionList: String {
        case closeTapped = "[MissionList] Close Tapped"             // 종료 버튼
        case refreshTapped = "[MissionList] Refresh Tapped"         // 다른 추천 버튼
        case infoIconTapped = "[MissionList] Info Icon Tapped"      // 다른 추천 info Icon
        case completeTapped = "[MissionList] Complete Tapped"       // 미션 선택 완료 버튼
        case selectedMissionDifficulty = "[MissionList] Selected Mission Difficulty" // 선택한 난이도들
    }
    
    // MARK: - 탭 바 (Tab Bar)
    enum Tab: String {
        case homeTapped = "[Tab] Home Tapped"
        case recordTapped = "[Tab] Record Tapped"
        case chartTapped = "[Tab] Chart Tapped"
        case myPageTapped = "[Tab] MyPage Tapped"
    }
    
    // MARK: - 홈 화면 (Home)
    enum Home: String {
        case streakButtonTapped = "[Home] Streak Button Tapped"         // 연속 달성일 버튼
        case characterTapped = "[Home] Character Tapped"               // 캐릭터
        case speechBubbleTapped = "[Home] Speech Bubble Tapped"         // 말풍선
        case todayMissionInfoTapped = "[Home] Today Mission Info Tapped" // 오늘의 미션 info
        case addMissionTapped = "[Home] Add Mission Tapped"             // 미션 추가하기
        case missionResultTapped = "[Home] Mission Result Tapped"       // 미션 수행 결과 버튼
        case completeMissionTapped = "[Home] Complete Mission Tapped"   // (바텀시트) 미션 완료
        case deleteMissionTapped = "[Home] Delete Mission Tapped"       // (바텀시트) 미션 삭제
        case confirmDeleteTapped = "[Home] Confirm Delete Tapped"       // (삭제 바텀시트) 최종 삭제
        case cancelDeleteTapped = "[Home] Cancel Delete Tapped"         // (삭제 바텀시트) 취소
    }
    
    // MARK: - 나의 기록 화면 (Record)
    enum Record: String {
        case prevMonthTapped = "[Record] Prev Month Tapped"    // 이전 달 이동
        case nextMonthTapped = "[Record] Next Month Tapped"    // 다음 달 이동
        case dateCellSelected = "[Record] Date Cell Selected"  // 날짜 셀 선택
    }
    
    // MARK: - 마이 페이지 화면 (MyPage)
    enum MyPage: String {
        case editProfileTapped = "[MyPage] Edit Profile Tapped"                // 프로필 편집
        case editInterestsTapped = "[MyPage] Edit Interests Tapped"            // 관심사 수정
        case leaveFeedbackTapped = "[MyPage] Leave Feedback Tapped"            // 의견 남기기
        case contactUsTapped = "[MyPage] Contact Us Tapped"                    // 문의하기
        case notificationSettingsTapped = "[MyPage] Notification Settings Tapped" // 알림 설정
        case termsOfServiceTapped = "[MyPage] Terms of Service Tapped"         // 서비스 이용약관
        case privacyPolicyTapped = "[MyPage] Privacy Policy Tapped"            // 개인정보 처리방침
        
        // 로그아웃 플로우
        case logoutTapped = "[MyPage] Logout Tapped"                           // 로그아웃 버튼 (팝업 띄우기 전)
        case logoutConfirmTapped = "[MyPage] Logout Confirm Tapped"            // 팝업 - 예(로그아웃 진행)
        case logoutCancelTapped = "[MyPage] Logout Cancel Tapped"              // 팝업 - 아니오(취소)
        
        // 회원 탈퇴 플로우
        case withdrawTapped = "[MyPage] Withdraw Tapped"                       // 회원 탈퇴 버튼 (팝업 띄우기 전)
        case withdrawConfirmTapped = "[MyPage] Withdraw Confirm Tapped"        // 팝업 - 탈퇴하기 진행
        case withdrawCancelTapped = "[MyPage] Withdraw Cancel Tapped"          // 팝업 - 취소
    }
}

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
    
    // RawRepresentable을 사용하여 String을 rawValue로 갖는 어떤 enum이든 받을 수 있게 만듦
    func track<T: RawRepresentable>(event: T, properties: [String: Any]? = nil) where T.RawValue == String {
        // 실제 Amplitude 전송 코드
        AppDelegate.amplitude?.track(eventType: event.rawValue, eventProperties: properties)
    }
}
