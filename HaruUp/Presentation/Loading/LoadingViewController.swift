//
//  LoadingViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/23/25.
//

import UIKit
import Lottie
import RxSwift
import RxCocoa

class LoadingViewController: UIViewController {
    
    let curationData: CurationData
    let viewModel: LoadingViewModel
    
    let coordinator: LoadingCoordinator?
    private let disposeBag = DisposeBag()
    
    private let viewDidAppearRelay = PublishRelay<Void>()
    
    private let loadingBoxes: [UIView] = (0..<6).map { _ in UIView() }
    
    private var pendingPhase2Shows = 0
    private var isTransitioningToPhase2 = false
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background_gradation.png")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let fullText = ""
        let highlightText = ""
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loadingCircle")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "입력하신 기본 정보를 분석하고 있어요.")
        label.textColor = .neutral700
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 박스 저장용 배열
    private var phase1Boxes: [UIView] = []
    private var phase2Boxes: [UIView] = []
    
    // 현재 표시된 박스 개수 추적
    private var currentPhase1BoxIndex = 0
    private var currentPhase2BoxIndex = 0
    private var isPhase2Started = false
    
    var onFinish: (() -> Void)? // 미션 분석 완료
    
    // MARK: - Init
    init(curationData: CurationData, viewModel: LoadingViewModel, coordinator: LoadingCoordinator) {
        self.curationData = curationData
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        createBoxes()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
        //        startLoadingAnimation()
        viewDidAppearRelay.accept(())
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(animationView)
        view.addSubview(descriptionLabel)
        view.addSubview(userInfoStackView)
        
        backgroundImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        
        let fullText = "\(curationData.nickname ?? "")님을 위한\n맞춤 미션을 만드는 중이에요!"
        let highlightText = "맞춤 미션"
        
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: Typography.title2.font,
                .foregroundColor: UIColor.black
            ]
        )
        let range = (fullText as NSString).range(of: highlightText)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.primaryBlue700,
            range: range
        )
        
        titleLabel.attributedText = attributedText
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 90,
            paddingLeft: 20,
            paddingRight: 20
            
        )
        
        
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 40,
            paddingRight: 40,
            height: 100
        )
        
        descriptionLabel.anchor(
            top: animationView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 55,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        userInfoStackView.anchor(
            top: descriptionLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 26,
            paddingLeft: 20,
            paddingRight: 20
        )
    }
    
    // 박스들을 미리 생성 (표시는 안함)
    private func createBoxes() {
        // Phase 1 박스들 (기본 정보)
        phase1Boxes = [
            createInfoBox(title: "성별", content: "\(curationData.gender ?? "")"),
            createInfoBox(title: "나이", content: "\(calculateAge())살"),
            createInfoBox(title: "직업", content: curationData.jobDetail?.jobDetailName ?? curationData.job?.jobName ?? "")
        ]
        
        // Phase 2 박스들 (관심사와 목표)
        phase2Boxes = [
            createInfoBox(title: "관심사", content: curationData.interest?.name ?? ""),
            createInfoBox(title: "세부 관심사", content: curationData.interestDetail?.name ?? ""),
            createInfoBox(title: "목표", content: curationData.goal?.name ?? "")
        ]
    }
    
    // ViewModel과 바인딩
    private func bind() {
        let input = LoadingViewModel.Input(
            viewDidAppear: viewDidAppearRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input, curationData: curationData)
        
        // 박스 표시 - 백엔드로부터 받은 인덱스에 따라
        output.showBox
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] boxIndex in
                guard let self = self else { return }
                self.showBoxAtIndex(boxIndex)
            })
            .disposed(by: disposeBag)
        
        // 로딩 완료 - LoadingCompleteViewController로 이동
        output.loadingCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] memberInterestIds in
                guard let self = self else { return }
                print("🚀 다음 화면으로 이동. 전달 데이터: \(memberInterestIds)")
                UserStorage.shared.selectedMemberInterestId = memberInterestIds.first
                
                self.onFinish?()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    // 박스 인덱스에 따라 적절한 박스 표시
    private func showBoxAtIndex(_ index: Int) {
        switch index {
        case 0, 1, 2:
            showNextPhase1Box()
            
        case 3: // 회원 관심사 정보 설정 완료 - Phase 2로 전환
            requestShowPhase2Boxes(count: 1)
            
        case 4: // 회원 목표 정보 설정 완료 - Phase 2 두번째 박스
            requestShowPhase2Boxes(count: 1)
            
        case 5: // 큐레이션 완료 - Phase 2 마지막 박스
            requestShowPhase2Boxes(count: 1)
            
        default:
            break
        }
    }
    
    // Phase 1 박스 하나씩 표시
    private func showNextPhase1Box() {
        guard currentPhase1BoxIndex < phase1Boxes.count else { return }
        
        let box = phase1Boxes[currentPhase1BoxIndex]
        
        // 처음 추가할 때만 스택뷰에 추가
        if box.superview == nil {
            userInfoStackView.addArrangedSubview(box)
            box.anchor(
                left: userInfoStackView.leftAnchor,
                right: userInfoStackView.rightAnchor,
                height: 50
            )
        }
        
        // 애니메이션으로 표시
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                box.alpha = 1
                box.transform = .identity
            }
        )
        
        currentPhase1BoxIndex += 1
    }
    
    private func requestShowPhase2Boxes(count: Int) {
        // phase2 이미 시작됐으면 바로 보여주기
        if isPhase2Started {
            for _ in 0..<count { showNextPhase2Box() }
            return
        }
        
        // 아직 phase2 시작 전이면 누적
        pendingPhase2Shows += count
        
        // 전환 애니메이션이 아직 시작 안 했으면 시작
        if !isTransitioningToPhase2 {
            transitionToPhase2()
        }
    }
    
    
    private func transitionToPhase2() {
        guard !isPhase2Started else { return }
        isTransitioningToPhase2 = true
        isPhase2Started = true
        
        updateDescriptionLabel(text: "입력하신 관심사와 목표를 분석하고 있어요")
        
        // phase1 박스 제거 애니메이션
        let group = DispatchGroup()
        phase1Boxes.forEach { box in
            group.enter()
            UIView.animate(withDuration: 0.35, animations: {
                box.alpha = 0
                box.transform = CGAffineTransform(translationX: 0, y: -20)
            }) { _ in
                box.removeFromSuperview()
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isTransitioningToPhase2 = false
            
            // ✅ 누적된 phase2 show 요청을 순서대로 처리
            let count = self.pendingPhase2Shows
            self.pendingPhase2Shows = 0
            
            for _ in 0..<count {
                self.showNextPhase2Box()
            }
        }
    }
    
    // Phase 2 박스 하나씩 표시
    private func showNextPhase2Box() {
        guard currentPhase2BoxIndex < phase2Boxes.count else { return }
        
        let box = phase2Boxes[currentPhase2BoxIndex]
        
        // 처음 추가할 때만 스택뷰에 추가
        if box.superview == nil {
            userInfoStackView.addArrangedSubview(box)
            box.anchor(
                left: userInfoStackView.leftAnchor,
                right: userInfoStackView.rightAnchor,
                height: 56
            )
        }
        
        // 애니메이션으로 표시
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                box.alpha = 1
                box.transform = .identity
            }
        )
        
        currentPhase2BoxIndex += 1
    }
    
    private func updateDescriptionLabel(text: String) {
        UIView.transition(
            with: descriptionLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.descriptionLabel.text = text
            }
        )
    }
    
    // MARK: - Helper Methods
    private func createInfoBox(title: String, content: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(named: "icon_small_check")
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.setStyle(Typography.body1, text: title)
        titleLabel.textColor = .neutral1000
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.setStyle(Typography.body1, text: content)
        contentLabel.textColor = .primaryBlue700
        contentLabel.textAlignment = .right
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12)
        ])
        
        return containerView
    }
    
    private func calculateAge() -> Int {
        guard let birthDateString = curationData.birthDate else { return 0 }
        
        // "20011029" 형식의 문자열을 파싱
        guard birthDateString.count == 8 else { return 0 }
        
        let yearString = String(birthDateString.prefix(4))
        let monthString = String(birthDateString.dropFirst(4).prefix(2))
        let dayString = String(birthDateString.suffix(2))
        
        guard let year = Int(yearString),
              let month = Int(monthString),
              let day = Int(dayString) else {
            return 0
        }
        
        // 생년월일 Date 객체 생성
        var birthDateComponents = DateComponents()
        birthDateComponents.year = year
        birthDateComponents.month = month
        birthDateComponents.day = day
        
        guard let birthDate = Calendar.current.date(from: birthDateComponents) else {
            return 0
        }
        
        // 현재 날짜와 비교하여 나이 계산
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: now)
        
        return ageComponents.year ?? 0
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: "큐레이션 로딩 중 오류가 발생했습니다.\n\(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToMissionComplete() {
        // 미션 추천 완료 화면으로 전환하는 로직
        // 예: coordinator를 통해 화면 전환
        // viewModel.navigateToMissionComplete()
        print("미션 추천 완료 화면으로 이동")
    }
}
