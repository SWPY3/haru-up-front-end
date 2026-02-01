//
//  MyPageViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa



class MyPageViewController: UIViewController {
    
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    // Coordinator 연결용
    var onEditProfile: (() -> Void)?
    var onEditInterest: (() -> Void)?
    var onNotificationSetting: (() -> Void)?
    var onLogout: (() -> Void)?
    var onWithdraw: (() -> Void)?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false // 스크롤 바 숨김 (선택사항)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "마이페이지")
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView(image: .characterHaruProfile)
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        //        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(.iconProfileEdit, for: .normal)
        //        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let jobLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .neutral900
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // GOAL 카드
    private let goalCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let goalBadgeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBlue600
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let goalBadgeLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "GOAL")
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goalNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let interestTag = MyPageTagView()
    private let detailTag = MyPageTagView()
    
    // 메뉴 리스트 스택 (버튼 5개)
    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.layer.cornerRadius = 14
        stack.clipsToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let editInterestBtn = MyPageMenuButton(title: "관심사 수정")
    private let feedbackBtn = MyPageMenuButton(title: "의견남기기")
    private let inquiryBtn = MyPageMenuButton(title: "문의하기")
    private let notificationSettingButton = MyPageMenuButton(title: "알림 설정")
    private let termsButton = MyPageMenuButton(title: "서비스 이용약관")
    private let privacyPolicyButton = MyPageMenuButton(title: "개인정보 처리방침")
    private let logoutBtn = MyPageMenuButton(title: "로그아웃", hasArrow: false)
    private let withdrawBtn = MyPageMenuButton(title: "탈퇴하기", hasArrow: false, isDestructive: true, showSeparator: false)
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral700
        label.setStyle(Typography.body4, text: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면이 나타날 때 네비게이션 바를 숨깁니다.
        // 이렇게 해야 Safe Area가 화면 최상단(Status Bar 바로 아래)부터 시작됩니다.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        print("우리가 사용하는 중요한 MemberInterestId: \(UserDefaultsManager.shared.selectedMemberInterestId)")
        print("토큰 스토리지에서 getInterests한 MemberId: \(TokenStorageService.shared.getMemberInterests()?.first?.memberId)")
        print("토큰 스토리지에서 getInterests한 memberInterestId: \(TokenStorageService.shared.getMemberInterests()?.first?.memberInterestId)")
    }
    
    private func setupUI() {
        view.backgroundColor = .neutral10

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, profileImageView, nicknameLabel, editProfileButton, jobLabel, goalCardView, menuStackView, versionLabel].forEach {
            contentView.addSubview($0)
        }
        
        [goalBadgeContainer, goalNameLabel, interestTag, detailTag].forEach {
            goalCardView.addSubview($0)
        }
        goalBadgeContainer.addSubview(goalBadgeLabel)
        
        [editInterestBtn, feedbackBtn, inquiryBtn, notificationSettingButton, termsButton, privacyPolicyButton, logoutBtn, withdrawBtn].forEach {
            menuStackView.addArrangedSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editProfileButton.leadingAnchor, constant: -8),
            
            editProfileButton.topAnchor.constraint(equalTo: nicknameLabel.topAnchor, constant: 10),
            editProfileButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            editProfileButton.widthAnchor.constraint(equalToConstant: 36),
            editProfileButton.heightAnchor.constraint(equalToConstant: 36),
            
            jobLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 3),
            jobLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            
            goalCardView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 36),
            goalCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            goalCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            //            goalCardView.heightAnchor.constraint(equalToConstant: 130),
            
            goalBadgeContainer.topAnchor.constraint(equalTo: goalCardView.topAnchor, constant: 15),
            goalBadgeContainer.leadingAnchor.constraint(equalTo: goalCardView.leadingAnchor, constant: 24),
            
            goalBadgeLabel.topAnchor.constraint(equalTo: goalBadgeContainer.topAnchor, constant: 2),
            goalBadgeLabel.bottomAnchor.constraint(equalTo: goalBadgeContainer.bottomAnchor, constant: -2),
            goalBadgeLabel.leadingAnchor.constraint(equalTo: goalBadgeContainer.leadingAnchor, constant: 6.5),
            goalBadgeLabel.trailingAnchor.constraint(equalTo: goalBadgeContainer.trailingAnchor, constant: -6.5),
            
            goalNameLabel.topAnchor.constraint(equalTo: goalBadgeContainer.bottomAnchor, constant: 5),
            goalNameLabel.leadingAnchor.constraint(equalTo: goalBadgeContainer.leadingAnchor),
            
            interestTag.topAnchor.constraint(equalTo: goalNameLabel.bottomAnchor, constant: 10),
            interestTag.bottomAnchor.constraint(equalTo: goalCardView.bottomAnchor, constant: -20),
            interestTag.leadingAnchor.constraint(equalTo: goalBadgeContainer.leadingAnchor),
            
            detailTag.centerYAnchor.constraint(equalTo: interestTag.centerYAnchor),
            detailTag.bottomAnchor.constraint(equalTo: goalCardView.bottomAnchor, constant: -20),
            detailTag.leadingAnchor.constraint(equalTo: interestTag.trailingAnchor, constant: 8),
            
            menuStackView.topAnchor.constraint(equalTo: goalCardView.bottomAnchor, constant: 24),
            menuStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            menuStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            versionLabel.topAnchor.constraint(equalTo: menuStackView.bottomAnchor, constant: 10),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func bind() {
        let input = MyPageViewModel.Input(
            viewDidLoad: Observable.just(()),
            viewWillAppear: rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in },
            editInterestTapped: editInterestBtn.rx.tap,
            feedbackTapped: feedbackBtn.rx.tap,
            inquiryTapped: inquiryBtn.rx.tap,
            logoutTapped: logoutBtn.rx.tap,
            withdrawTapped: withdrawBtn.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.curationData
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                
                // 1. 닉네임
                guard let nickname = data.nickname else {
                    self.nicknameLabel.setStyle(Typography.subtitle1, text: "사용자")
                    self.nicknameLabel.textColor = .black
                    return
                }
                
                self.nicknameLabel.setStyle(Typography.subtitle1, text: "\(nickname)님")
                self.nicknameLabel.textColor = .black
                
                // 캐릭터 이미지
                let characterId = data.characterId ?? 1
                let characterImage: UIImage = characterId == 1 ? .characterHaruProfile : .characterNaruProfile
                profileImageView.image = characterImage
                
                // 2. 직업 상세
                let jobDisplayText = data.jobDetail?.jobDetailName ?? data.job?.jobName ?? "직업 정보 없음"
                self.jobLabel.setStyle(Typography.body1, text: jobDisplayText)
                self.jobLabel.textColor = .neutral900
                
                // 3. 목표 이름
                self.goalNameLabel.setStyle(Typography.body1, text: data.goal?.name ?? "목표를 설정해보세요")
                self.goalNameLabel.textColor = .black
                
                // 4. 태그 (TagView 내부에서 setStyle을 사용하도록 설계되어 있다면 그대로 사용)
                self.interestTag.configure(
                    text: data.interest?.name ?? "",
                    emoji: Interest.iconForInterest(name: data.interest?.name ?? "")
                )
                self.detailTag.configure(text: data.interestDetail?.name ?? "")
                
                print("닉네임: \(data.nickname ?? "없음")")
                print("세부직업: \(data.jobDetail?.jobDetailName ?? "없음")")
            })
            .disposed(by: disposeBag)
        
        output.appVersion
            .drive(onNext: { [weak self] versionText in
                self?.versionLabel.setStyle(Typography.body4, text: versionText)
                self?.versionLabel.textColor = .neutral700
            })
            .disposed(by: disposeBag)
        
        // 로그아웃 Alert 표시
        output.showLogoutAlert
            .emit(onNext: { [weak self] in
                self?.showLogoutConfirmationAlert()
            })
            .disposed(by: disposeBag)
        
        // 탈퇴 첫 번째 Alert 표시
        output.showWithdrawFirstAlert
            .emit(onNext: { [weak self] in
                self?.showWithdrawFirstConfirmationAlert()
            })
            .disposed(by: disposeBag)
        
        // 탈퇴 성공 Alert 표시
        output.showWithdrawSuccessAlert
            .emit(onNext: { [weak self] in
                self?.showWithdrawSuccessAlert()
            })
            .disposed(by: disposeBag)
        
        // 로그아웃 성공
        output.logoutSuccess
            .emit(onNext: { [weak self] in
                self?.onLogout?()
            })
            .disposed(by: disposeBag)
        
        // 탈퇴 성공
        output.withdrawSuccess
            .emit(onNext: { [weak self] in
                self?.onWithdraw?()
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지
        output.errorMessage
            .emit(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        editProfileButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onEditProfile?() // 코디네이터에게 알림
            })
            .disposed(by: disposeBag)
        
        // 의견남기기 이동 (Google Forms)
        feedbackBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let url = URL(string: "https://forms.gle/qC5jrp4FL89CcdoA6") else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            .disposed(by: disposeBag)
        
        // 문의하기 이동 (Google Forms)
        inquiryBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let url = URL(string: "https://forms.gle/MP4LuXLJDd13vo5W9") else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            .disposed(by: disposeBag)
        
        // 이용약관 이동
        termsButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let url = URL(string: "https://melodic-roar-3e1.notion.site/2e0849f596f380eabc6de523ab0d9bd9") else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            .disposed(by: disposeBag)
        
        // 개인정보 처리방침 이동
        privacyPolicyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let url = URL(string: "https://melodic-roar-3e1.notion.site/2e0849f596f380969043ee98e361c7bf") else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            .disposed(by: disposeBag)
        
        
        editInterestBtn.rx.tap
            .subscribe(onNext: { [weak self] in self?.onEditInterest?() })
            .disposed(by: disposeBag)
        
        notificationSettingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onNotificationSetting?() // 코디네이터에게 알림
            })
            .disposed(by: disposeBag)
    }
    
    private func showLogoutConfirmationAlert() {
        let alert = MyPageAlertViewController(
            title: "로그아웃을 진행할까요?",
            message: "다음 접속 시 계정 정보를\n 다시 입력해야 해요.",
            type: .confirmation,
            confirmTitle: "예",
            cancelTitle: "아니오",
            confirmColor: .primaryBlue700,
            cancelColor: .neutral700
        )
        
        alert.onConfirm = { [weak self] in
            self?.handleLogout()
        }
        
        present(alert, animated: true)
    }
    
    // 탈퇴 첫 번째 확인 Alert
    private func showWithdrawFirstConfirmationAlert() {
        let alert = MyPageAlertViewController(
            title: "😢 정말 저희를 떠나실 건가요?",
            message: "탈퇴 시, 모든 기록이 사라지며\n복구할 수 없어요.",
            type: .confirmation,
            confirmTitle: "탈퇴하기",
            cancelTitle: "취소",
            confirmColor: .primaryBlue700,
            cancelColor: .neutral700
        )
        alert.onConfirm = { [weak self] in
            self?.handleWithdraw()
        }
        present(alert, animated: true)
    }
    
    // 탈퇴 성공 Alert
    private func showWithdrawSuccessAlert() {
        let alert = MyPageAlertViewController(
            title: "탈퇴가 완료되었습니다.",
            message: "더 좋은 서비스를 준비할게요.\n다음에 다시 만나요!",
            type: .success,
            confirmTitle: "확인"
        )
        alert.onConfirm = { [weak self] in
            self?.onWithdraw?()
        }
        present(alert, animated: true)
    }
    
    // 에러 Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        present(alert, animated: true)
    }
    
    // 로그아웃 처리
    private func handleLogout() {
        viewModel.performLogout()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.onLogout?()
            }, onFailure: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    // 탈퇴 처리
    private func handleWithdraw() {
        viewModel.performWithdraw()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                // 탈퇴 성공 Alert 표시
                self?.showWithdrawSuccessAlert()
                // 탈퇴할 때, 사용자의 미션 선택 여부가 초기화 - UserDefaults로 미션 선택 여부를 저장중이라, 탈퇴할 때 그 정보를 지워야함.
                // TODO: UserDefaults 초기화하는 것 별도로 만들 필요성이 있음 - 조영현
                UserDefaults.standard.removeObject(forKey: UserDefaultsKey.todayMissionSelectedDate)
            }, onFailure: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
