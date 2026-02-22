//
//  ProfileEditViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/31/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileEditViewController: UIViewController {
    // MARK: - UI Components
    
    private let buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.chevronLeft, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "프로필 수정")
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "닉네임 변경")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.font = Typography.body1.font
        tf.textColor = .neutral1000
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let clearButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.iconX, for: .normal)
        btn.isHidden = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let textFieldBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .cta
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryRed200
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let jobTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "직업")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let jobArrowImageView: UIImageView = {
        let img = UIImage(named: "chevron_bottom")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    // 직업 선택 버튼
    private lazy var jobSelectButton: UIButton = {
        var config = UIButton.Configuration.plain()
    
        let profile = TokenStorageService.shared.getProfile()
        let initialTitle = profile.jobName ?? "직업선택"
        let titleColor: UIColor = profile.jobName != nil ? .cta : .neutral800
        
        var titleAttr = AttributedString(initialTitle)
        titleAttr.font = Typography.body1.font
        titleAttr.foregroundColor = titleColor
        config.attributedTitle = titleAttr
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        btn.contentHorizontalAlignment = .left
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.neutral200.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addSubview(jobArrowImageView)
        NSLayoutConstraint.activate([
            jobArrowImageView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            jobArrowImageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        return btn
    }()
    
    private let detailJobTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "세부 직무")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailJobArrowImageView: UIImageView = {
        let img = UIImage(named: "chevron_bottom")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    
    private lazy var detailJobSelectButton: UIButton = {
        var config = UIButton.Configuration.plain()

        let profile = TokenStorageService.shared.getProfile()
        let initialTitle = profile.jobDetailName ?? "세부 직무 선택"
        let titleColor: UIColor = profile.jobDetailName != nil ? .cta : .neutral800
        
        var titleAttr = AttributedString(initialTitle)
        titleAttr.font = Typography.body1.font
        titleAttr.foregroundColor = titleColor
        config.attributedTitle = titleAttr
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        btn.contentHorizontalAlignment = .left
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.neutral200.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addSubview(detailJobArrowImageView)
        NSLayoutConstraint.activate([
            detailJobArrowImageView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            detailJobArrowImageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        
        return btn
    }()
    
    private let detailJobWarningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryRed200
        label.textAlignment = .left
        label.font = Typography.body4.font // 또는 원하시는 폰트
        label.isHidden = true // 기본적으로 숨김
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.backgroundColor = .neutral200
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let jobDropdown = DropdownView()
    private let detailJobDropdown = DropdownView()
    
    // MARK: - Properties
    private let viewModel: ProfileEditViewModel
    private let disposeBag = DisposeBag()
    private var completeButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    init(viewModel: ProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        // 탭바 숨김 설정 (중요: init에서 설정해야 push될 때 적용됨)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupAttributes()
        setupKeyboardHandling()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        var parent = self.parent
        while parent != nil {
            if let tabBar = parent as? MainTabBarController {
                tabBar.setTabBarHidden(true, animated: animated)
                break
            }
            parent = parent?.parent
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        nicknameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nicknameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        var parent = self.parent
        while parent != nil {
            if let tabBar = parent as? MainTabBarController {
                tabBar.setTabBarHidden(false, animated: animated)
                break
            }
            parent = parent?.parent
        }
    }
    
    // MARK: - Setup Methods
    private func setupAttributes() {
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup & Bind
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        [customNavBar, nicknameTitleLabel, textFieldContainer, warningLabel,
         jobTitleLabel, jobSelectButton,
         detailJobTitleLabel, detailJobSelectButton,
         detailJobWarningLabel,
         buttonBackgroundView,
         completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.addSubview(jobDropdown)
        view.addSubview(detailJobDropdown)
        
        jobDropdown.isHidden = true
        detailJobDropdown.isHidden = true
        jobDropdown.translatesAutoresizingMaskIntoConstraints = false
        detailJobDropdown.translatesAutoresizingMaskIntoConstraints = false
        
        [backButton, navTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            customNavBar.addSubview($0)
        }
        
        [nicknameTextField, clearButton, textFieldBottomLine].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            textFieldContainer.addSubview($0)
        }
    }
    
    private func setupConstraints() {
//        completeButtonBottomConstraint = completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        completeButtonBottomConstraint = completeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        
        NSLayoutConstraint.activate([
            // 1. 좌우는 화면 꽉 채우기
            buttonBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 2. 바닥은 화면 끝까지 (Safe Area 무시하고 채움)
            buttonBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 3. [핵심] 윗부분은 완료 버튼보다 5만큼 더 위로 올라오게 설정
            // (완료 버튼이 키보드에 의해 올라가면, 이 뷰도 같이 따라서 늘어납니다)
            buttonBackgroundView.topAnchor.constraint(equalTo: completeButton.topAnchor, constant: -5),
            
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 56),
            
            backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            navTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 13),
            
            nicknameTitleLabel.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 32),
            nicknameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            textFieldContainer.topAnchor.constraint(equalTo: nicknameTitleLabel.bottomAnchor, constant: 8),
            textFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 48),
            
            nicknameTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            nicknameTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            nicknameTextField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            nicknameTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            
            clearButton.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24),
            
            textFieldBottomLine.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            textFieldBottomLine.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            textFieldBottomLine.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textFieldBottomLine.heightAnchor.constraint(equalToConstant: 2),
            
            warningLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 6),
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Job Selection UI Constraints
            jobTitleLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 40),
            jobTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            jobSelectButton.topAnchor.constraint(equalTo: jobTitleLabel.bottomAnchor, constant: 8),
            jobSelectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            jobSelectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            jobSelectButton.heightAnchor.constraint(equalToConstant: 55),
            
            detailJobTitleLabel.topAnchor.constraint(equalTo: jobSelectButton.bottomAnchor, constant: 24),
            detailJobTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            detailJobSelectButton.topAnchor.constraint(equalTo: detailJobTitleLabel.bottomAnchor, constant: 8),
            detailJobSelectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailJobSelectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailJobSelectButton.heightAnchor.constraint(equalToConstant: 55),
            
            detailJobWarningLabel.topAnchor.constraint(equalTo: detailJobSelectButton.bottomAnchor, constant: 6),
            detailJobWarningLabel.leadingAnchor.constraint(equalTo: detailJobSelectButton.leadingAnchor),
            detailJobWarningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Dropdowns (Button 바로 아래 위치)
            jobDropdown.topAnchor.constraint(equalTo: jobSelectButton.bottomAnchor, constant: 4),
            jobDropdown.leadingAnchor.constraint(equalTo: jobSelectButton.leadingAnchor),
            jobDropdown.trailingAnchor.constraint(equalTo: jobSelectButton.trailingAnchor),
            jobDropdown.heightAnchor.constraint(equalToConstant: 200), // 최대 높이
            
            detailJobDropdown.topAnchor.constraint(equalTo: detailJobSelectButton.bottomAnchor, constant: 4),
            detailJobDropdown.leadingAnchor.constraint(equalTo: detailJobSelectButton.leadingAnchor),
            detailJobDropdown.trailingAnchor.constraint(equalTo: detailJobSelectButton.trailingAnchor),
            detailJobDropdown.heightAnchor.constraint(equalToConstant: 200),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 56),
            completeButtonBottomConstraint!
        ])
    }
    
    private func bind() {
        // 1. Back Button Action
        // "현재 화면의 값"과 "저장된 값"을 실시간으로 비교하여 처리
        backButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                // 1. 현재 로컬 스토리지에 저장된 값 가져오기
                let saved = TokenStorageService.shared.getProfile()
                
                // 2. 현재 화면의 값
                let currentNickname = owner.nicknameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                let currentJobId = owner.viewModel.selectedJobRelay.value?.id
                var currentDetailId = owner.viewModel.selectedDetailJobRelay.value?.id
                
                // 3. 비교하기 (저장된 값 vs 현재 값)
                // 닉네임이 다른가? (저장된 닉네임이 없으면 빈 문자열과 비교)
                let isNicknameChanged = currentNickname != (saved.nickname ?? "")
                
                // 직업이 다른가?
                let savedJobId = saved.jobId == 0 ? nil : saved.jobId
                let isJobChanged = currentJobId != savedJobId
                
                // 세부 직무가 다른가?
                currentDetailId = (currentDetailId == 0) ? nil : currentDetailId
                let savedDetailId = saved.jobDetailId == 0 ? nil : saved.jobDetailId
//                let isDetailChanged = currentDetailId != savedDetailId
                
                // 자영업인 경우 세부직무 비교를 무시
                var isDetailChanged = false
                
                // 현재 선택된 직업이 자영업이 아닐 때만 세부직무 비교
                let currentJobName = owner.viewModel.selectedJobRelay.value?.jobName
                if currentJobName != "자영업" {
                    isDetailChanged = currentDetailId != savedDetailId
                }
                
                // 4. 하나라도 다르면(수정 중이면) Alert, 아니면 바로 Pop
                if isNicknameChanged || isJobChanged || isDetailChanged {
                    owner.showCancelAlert()
                } else {
                    owner.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // 2. Clear Button UI Action
        clearButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.resetTextField()
            })
            .disposed(by: disposeBag)
        
        // 3. Clear Button Visibility
        nicknameTextField.rx.text.orEmpty
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .bind(to: clearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 4. 포커스 애니메이션 (ControlEvent 활용)
        nicknameTextField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.animateBottomLine()
            })
            .disposed(by: disposeBag)
        
        // 타이핑 시작하면 경고 숨김
        nicknameTextField.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.warningLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // --- ViewModel Binding ---
        let input = ProfileEditViewModel.Input(
            nicknameInput: nicknameTextField.rx.text.orEmpty.asObservable(),
            clearButtonTapped: clearButton.rx.tap.asObservable(),
            completeButtonTapped: completeButton.rx.tap.asObservable(),
            
            // Job 관련 이벤트 전달
            jobButtonTapped: jobSelectButton.rx.tap.asObservable(),
            detailJobButtonTapped: detailJobSelectButton.rx.tap.asObservable(),
            jobSelected: jobDropdown.itemSelected.asObservable(),
            detailJobSelected: detailJobDropdown.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        
        // Job Binding
        // 1. 직업 목록 데이터 바인딩
        Driver.combineLatest(output.jobList, output.selectedJobId)
            .drive(with: self, onNext: { owner, data in
                print("💻 JobDropdown 데이터 바인딩: \(data.0.count)건")
                owner.jobDropdown.bind(items: data.0, selectedId: data.1)
            })
            .disposed(by: disposeBag)
        
        // 2. 세부직무 목록 데이터 바인딩
        Driver.combineLatest(output.detailJobList, output.selectedDetailJobId)
            .drive(with: self, onNext: { owner, data in
                print("💻 DetailJobDropdown 데이터 바인딩: \(data.0.count)건")
                owner.detailJobDropdown.bind(items: data.0, selectedId: data.1)
            })
            .disposed(by: disposeBag)
        
        // 2-1. 세부직무 버튼 활성화/비활성화 상태 바인딩 (추가)
        output.isDetailJobEnabled
            .drive(with: self, onNext: { owner, isEnabled in
                owner.detailJobSelectButton.isEnabled = isEnabled
                
                if isEnabled {
                    // 활성화 상태: 정상 UI
                    owner.detailJobSelectButton.alpha = 1.0
                    owner.detailJobSelectButton.layer.borderColor = UIColor.neutral200.cgColor
                } else {
                    // 비활성화 상태: 반투명 + 회색 처리
                    owner.detailJobSelectButton.alpha = 0.5
                    owner.detailJobSelectButton.layer.borderColor = UIColor.neutral200.cgColor
                    
                    // 비활성화 시 타이틀 초기화
                    owner.detailJobSelectButton.setAttributedTitle(
                        NSAttributedString(
                            string: "세부 직무 선택",
                            attributes: [.font: Typography.body1.font, .foregroundColor: UIColor.neutral800]
                        ),
                        for: .normal
                    )
                    
                    // 드롭다운이 열려있으면 닫기
                    if !owner.detailJobDropdown.isHidden {
                        owner.detailJobDropdown.isHidden = true
                        owner.updateDropdownState(
                            button: owner.detailJobSelectButton,
                            arrow: owner.detailJobArrowImageView,
                            isOpen: false
                        )
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 3. 직업 선택 상태 업데이트 (버튼 타이틀만 업데이트)
        output.currentJobName
            .drive(with: self, onNext: { owner, name in
                let title = name ?? "직업 선택"
                let color: UIColor = name != nil ? .cta : .neutral800
                
                owner.jobSelectButton.setAttributedTitle(
                    NSAttributedString(
                        string: title,
                        attributes: [.font: Typography.body1.font, .foregroundColor: color]
                    ),
                    for: .normal
                )
                
                // 선택 완료 시 드롭다운 닫기 + UI 원래 상태로 복귀
                if name != nil {
                    owner.jobDropdown.isHidden = true
                    owner.updateDropdownState(
                        button: owner.jobSelectButton,
                        arrow: owner.jobArrowImageView,
                        isOpen: false
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // 4. 세부 직무 선택 상태 업데이트 (버튼 타이틀 변경 로직)
        output.currentDetailJobName
            .drive(with: self, onNext: { owner, name in
                
                var titleText = ""
                var titleColor: UIColor = .neutral800
                
                // 1. 세부 직무가 선택되어 있는지 확인
                if let selectedName = name {
                    // [선택됨] -> 해당 직무 이름 표시 & 색상 강조
                    titleText = selectedName
                    titleColor = .cta
                } else {
                    // [선택 안 됨] -> Placeholder 표시 (직업에 따라 문구 분기)
                    // 현재 선택된 직업이 무엇인지 확인
                    let currentJobName = owner.viewModel.selectedJobRelay.value?.jobName
                    
                    if ["학생", "취준생"].contains(currentJobName) {
                        titleText = "하고 싶은 세부 직무 선택"
                    } else {
                        titleText = "세부 직무 선택"
                    }
                    titleColor = .neutral800
                }
                
                // 2. 버튼 UI 업데이트
                owner.detailJobSelectButton.setAttributedTitle(
                    NSAttributedString(
                        string: titleText,
                        attributes: [.font: Typography.body1.font, .foregroundColor: titleColor]
                    ),
                    for: .normal
                )
                
                // 3. 선택 완료 시 드롭다운 닫기 + 화살표 원복 (기존 로직 유지)
                if name != nil {
                    owner.detailJobDropdown.isHidden = true
                    owner.updateDropdownState(
                        button: owner.detailJobSelectButton,
                        arrow: owner.detailJobArrowImageView,
                        isOpen: false
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // 5. 직업 버튼 탭 -> 드롭다운 토글
        jobSelectButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.jobDropdown.isHidden.toggle()
                owner.detailJobDropdown.isHidden = true // 다른 드롭다운 닫기
                owner.view.endEditing(true)
                
                // 드롭다운 상태에 따라 UI 업데이트
                let isOpen = !owner.jobDropdown.isHidden
                owner.updateDropdownState(
                    button: owner.jobSelectButton,
                    arrow: owner.jobArrowImageView,
                    isOpen: isOpen
                )
            })
            .disposed(by: disposeBag)
        
        // 6. 세부직무 버튼 탭 -> 드롭다운 토글
        detailJobSelectButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                // 비활성화 상태면 무시
                if !owner.detailJobSelectButton.isEnabled { return }
                
                // 직업 선택 안 되어 있으면 방어
                if owner.jobSelectButton.currentAttributedTitle?.string == "직업 선택" { return }
                
                owner.detailJobDropdown.isHidden.toggle()
                owner.jobDropdown.isHidden = true // 다른 드롭다운 닫기
                owner.view.endEditing(true)
                
                // 드롭다운 상태에 따라 UI 업데이트
                let isOpen = !owner.detailJobDropdown.isHidden
                owner.updateDropdownState(
                    button: owner.detailJobSelectButton,
                    arrow: owner.detailJobArrowImageView,
                    isOpen: isOpen
                )
            })
            .disposed(by: disposeBag)
        
        // 7. 직업 드롭다운이 닫힐 때 원래 상태로 복귀
        jobDropdown.rx.observe(Bool.self, "isHidden")
            .compactMap { $0 }
            .filter { $0 == true } // 닫힐 때만
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateDropdownState(
                    button: self.jobSelectButton,
                    arrow: self.jobArrowImageView,
                    isOpen: false
                )
            })
            .disposed(by: disposeBag)
        
        // 8. 세부직무 드롭다운이 닫힐 때 원래 상태로 복귀
        detailJobDropdown.rx.observe(Bool.self, "isHidden")
            .compactMap { $0 }
            .filter { $0 == true } // 닫힐 때만
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateDropdownState(
                    button: self.detailJobSelectButton,
                    arrow: self.detailJobArrowImageView,
                    isOpen: false
                )
            })
            .disposed(by: disposeBag)
        
        // ----------------------------------------
        
        // 1. 초기 닉네임
        output.initialNickname
            .drive(nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        // 2. 완료 버튼 활성화 상태
        output.isCompleteEnabled
            .drive(with: self, onNext: { owner, isEnabled in
                owner.completeButton.isEnabled = isEnabled
                owner.completeButton.backgroundColor = isEnabled ? .cta : .neutral200
            })
            .disposed(by: disposeBag)
        
        // 3. 유효성 검사 결과 처리 (경고 메시지 표시)
        output.validationResult
            .emit(with: self, onNext: { owner, result in
                owner.handleValidationResult(result)
            })
            .disposed(by: disposeBag)
        
        // 4. 최종 성공 처리 (토스트 -> 화면 종료)
        output.updateSuccess
            .emit(with: self, onNext: { owner, isNicknameChanged in
                owner.view.endEditing(true)
                
                // 닉네임 변경 후 홈화면 사용자 정보 다시 가져오게 갱신
                NotificationCenter.default.post(name: .changedProfile, object: nil)
                
                // 토스트 메시지 표시
                if isNicknameChanged {
                    owner.showToast(message: " 닉네임 변경이 완료되었어요")
                } else {
                    owner.showToast(message: " 직업 정보가 변경되었어요")
                }
                
                // 완료 버튼 즉시 비활성화
                // Rx 이벤트 전달 속도 차이를 방지하기 위해 UI에서 즉시 꺼버리기
                owner.completeButton.isEnabled = false
                owner.completeButton.backgroundColor = .neutral200
            })
            .disposed(by: disposeBag)
        
        // 5. 직업 선택 경고 메시지 바인딩
        output.jobWarning
            .drive(with: self, onNext: { owner, warningMessage in
                if let message = warningMessage {
                    // 경고 메시지가 있으면(직업은 골랐는데 세부직무가 없으면) 텍스트 설정 및 보이기
                    owner.detailJobWarningLabel.text = message
                    owner.detailJobWarningLabel.isHidden = false
                    owner.detailJobWarningLabel.font = Typography.body4.font
                    
                    // (선택사항) 경고가 떴을 때 버튼 테두리를 빨간색으로 바꾸고 싶다면:
                    // owner.detailJobSelectButton.layer.borderColor = UIColor.secondaryRed200.cgColor
                } else {
                    // nil이면(정상 상태면) 숨기기
                    owner.detailJobWarningLabel.isHidden = true
                    
                    // (선택사항) 테두리 색상 원복 (활성화/비활성화 로직이 따로 있어서 생략 가능)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    private func updateDropdownState(button: UIButton, arrow: UIImageView, isOpen: Bool) {
        let upImage = UIImage(named: "chevron_top")?.withRenderingMode(.alwaysTemplate)
        let downImage = UIImage(named: "chevron_bottom")?.withRenderingMode(.alwaysTemplate)
        
        if isOpen {
            // 드롭다운 열림: 테두리 파란색, 화살표 위
            button.layer.borderColor = UIColor.cta.cgColor
            button.layer.borderWidth = 1
            arrow.image = upImage
            arrow.tintColor = .cta
        } else {
            // 드롭다운 닫힘: 테두리 회색, 화살표 아래
            button.layer.borderColor = UIColor.neutral200.cgColor
            button.layer.borderWidth = 1
            arrow.image = downImage
            arrow.tintColor = .neutral800
        }
    }
    
    @objc private func dismissKeyboard() {
        // 드롭다운이 열려있으면 닫아주는 로직 추가
        if !jobDropdown.isHidden {
            jobDropdown.isHidden = true
            updateDropdownState(button: jobSelectButton, arrow: jobArrowImageView, isOpen: false)
        }
        if !detailJobDropdown.isHidden {
            detailJobDropdown.isHidden = true
            updateDropdownState(button: detailJobSelectButton, arrow: detailJobArrowImageView, isOpen: false)
        }
        view.endEditing(true)
    }
    
    // MARK: - Logic Methods
    private func showCancelAlert() {
        let alert = MyPageAlertViewController(
            title: "수정을 취소하시겠습니까?",
            message: "완료를 누르지 않으면,\n수정사항은 변경되지 않아요.",
            type: .confirmation,
            confirmTitle: "예",
            cancelTitle: "아니오",
            confirmColor: .primaryBlue700,
            cancelColor: .neutral700
        )
        
        // '예'를 눌렀을 때만 뒤로가기 실행
        alert.onConfirm = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.present(alert, animated: false)
    }
    
    // MARK: - Private Helper Methods
    private func handleValidationResult(_ result: NicknameValidationResult) {
        switch result {
        case .success:
            warningLabel.isHidden = true
            
        case .empty:
            break
            
        case .tooShort, .tooLong:
            showWarning("*2~10자로 입력해주세요.")
            
        case .invalidCharacters:
            showWarning("*한글만 입력해주세요.")
            
        case .incompleteKorean:
            showWarning("*올바른 형태로 입력해주세요.")
            
        case .duplicated:
            showWarning("*이미 존재하는 닉네임입니다.")
        }
    }
    
    private func animateBottomLine() {
        let isFocused = nicknameTextField.isFirstResponder
        UIView.animate(withDuration: 0.3) {
            self.textFieldBottomLine.backgroundColor = isFocused ? .systemBlue : UIColor.primaryBlue700.withAlphaComponent(0.3)
        }
    }
    
    private func showWarning(_ text: String) {
        warningLabel.setStyle(Typography.body4, text: text)
        warningLabel.isHidden = false
        //        textFieldBottomLine.backgroundColor = .systemRed
        completeButton.backgroundColor = .neutral200
    }
    
    private func resetTextField() {
        nicknameTextField.text = ""
        nicknameTextField.sendActions(for: .editingChanged) // Rx에 '빈 값'임을 알림
        warningLabel.isHidden = true
    }
    
    private func showToast(message: String) {
        // 기존 코드와 동일한 토스트 로직 (생략 가능하나 완전성을 위해 포함)
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 144/255, green: 149/255, blue: 158/255, alpha: 1.0)
        toastContainer.layer.cornerRadius = 27
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: message)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: .iconSmallCheck)
        //        icon.tintColor = .systemBlue
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        
        view.addSubview(toastContainer)
        toastContainer.addSubview(icon)
        toastContainer.addSubview(label)
        
        NSLayoutConstraint.activate([
            toastContainer.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -20),
            toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastContainer.heightAnchor.constraint(equalToConstant: 54),
            
            icon.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            
            label.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -20),
        ])
        
        toastContainer.alpha = 0
        //        UIView.animate(withDuration: 0.3) { toastContainer.alpha = 1 }
        // 1. 페이드 인 (0.3초)
        UIView.animate(withDuration: 0.3, animations: {
            toastContainer.alpha = 1
        }) { _ in
            // 2. 2초 대기 후 페이드 아웃
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0
            }) { _ in
                // 3. 뷰 계층에서 제거
                toastContainer.removeFromSuperview()
            }
        }
    }
}

// MARK: - Keyboard Handling Extension
extension ProfileEditViewController: UIGestureRecognizerDelegate {
    // 스와이프 제스처를 허용할지 결정하는 메서드
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // interactivePopGestureRecognizer인 경우 false를 반환하여 스와이프를 막음
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        completeButtonBottomConstraint?.constant = -keyboardFrame.height - 10
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        completeButtonBottomConstraint?.constant = -60
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 버튼이나 테이블뷰 셀 터치 시 제스처 무시 (드롭다운 터치 문제 방지)
        if touch.view is UIButton || touch.view?.superview is UITableViewCell {
            return false
        }
        return true
    }
}
