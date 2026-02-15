//
//  InterestEditViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/2/26.
//

import UIKit
import RxSwift
import RxCocoa

final class InterestEditViewController: UIViewController {
    // MARK: - UI Components
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
        label.setStyle(Typography.title3, text: "관심사 수정")
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body1, text: "관심사를 수정해도 캐릭터의 성장도는 유지돼요.")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 관심사 선택 UI
    private let interestTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "관심사")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let interestArrowImageView: UIImageView = {
        let img = UIImage(named: "chevron_bottom")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private lazy var interestSelectButton: UIButton = {
        let btn = UIButton()
        let interests = TokenStorageService.shared.getMemberInterests()?.first
        let path = interests?.directFullPath ?? []
        let initialTitle = (path.indices.contains(0) ? path[0] : nil) ?? "관심사 선택"
        let titleColor: UIColor = (path.indices.contains(0)) ? .cta : .neutral800
        btn.setAttributedTitle(
            NSAttributedString(
                string: initialTitle,
                attributes: [.font: Typography.body1.font, .foregroundColor: titleColor]
            ),
            for: .normal
        )
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.neutral200.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addSubview(interestArrowImageView)
        NSLayoutConstraint.activate([
            interestArrowImageView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            interestArrowImageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        return btn
    }()
    
    // MARK: - 세부 관심사 선택 UI
    private let detailInterestTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "세부 관심사")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailInterestArrowImageView: UIImageView = {
        let img = UIImage(named: "chevron_bottom")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private lazy var detailInterestSelectButton: UIButton = {
        let btn = UIButton()
        let interests = TokenStorageService.shared.getMemberInterests()?.first
        let path = interests?.directFullPath ?? []
        
        // Path의 1번째 인덱스가 세부 관심사
        let initialTitle = (path.indices.contains(1) ? path[1] : nil) ?? "세부 관심사 선택"
        let titleColor: UIColor = (path.indices.contains(1)) ? .cta : .neutral800
        btn.setAttributedTitle(
            NSAttributedString(
                string: initialTitle,
                attributes: [.font: Typography.body1.font, .foregroundColor: titleColor]
            ),
            for: .normal
        )
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.neutral200.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addSubview(detailInterestArrowImageView)
        NSLayoutConstraint.activate([
            detailInterestArrowImageView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            detailInterestArrowImageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        
        return btn
    }()
    
    // MARK: - 목표 선택 UI
    private let goalTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "목표")
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goalArrowImageView: UIImageView = {
        let img = UIImage(named: "chevron_bottom")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private lazy var goalSelectButton: UIButton = {
        let btn = UIButton()
        let interests = TokenStorageService.shared.getMemberInterests()?.first
        let path = interests?.directFullPath ?? []
        
        // Path의 2번째 인덱스가 목표
        let initialTitle = (path.indices.contains(2) ? path[2] : nil) ?? "목표 선택"
        let titleColor: UIColor = (path.indices.contains(2)) ? .cta : .neutral800
        btn.setAttributedTitle(
            NSAttributedString(
                string: initialTitle,
                attributes: [.font: Typography.body1.font, .foregroundColor: titleColor]
            ),
            for: .normal
        )
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.neutral200.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addSubview(goalArrowImageView)
        NSLayoutConstraint.activate([
            goalArrowImageView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            goalArrowImageView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        
        return btn
    }()
    
    private let foreignLanguageInputRelay = PublishRelay<String>()
    private weak var currentGoalBottomSheet: GoalInputBottomSheet?
    private let goalInputTextRelay = PublishRelay<String>()
    
    private let goalWarningLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "")
        label.textColor = .secondaryRed200
        label.isHidden = true
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
    
    private let interestDropdown = DropdownView()
    private let detailInterestDropdown = DropdownView()
    private let goalDropdown = DropdownView()
    
    // MARK: - Properties
    private let viewModel: InterestEditViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: InterestEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupAttributes()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var parent = self.parent
        while parent != nil {
            if let tabBar = parent as? MainTabBarController {
                tabBar.setTabBarHidden(true, animated: animated)
                break
            }
            parent = parent?.parent
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        [customNavBar, descriptionLabel,
         interestTitleLabel, interestSelectButton,
         detailInterestTitleLabel, detailInterestSelectButton,
         goalTitleLabel, goalSelectButton,
         completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.addSubview(interestDropdown)
        view.addSubview(detailInterestDropdown)
        view.addSubview(goalDropdown)
        view.addSubview(goalWarningLabel)
        
        interestDropdown.isHidden = true
        detailInterestDropdown.isHidden = true
        goalDropdown.isHidden = true
        interestDropdown.translatesAutoresizingMaskIntoConstraints = false
        detailInterestDropdown.translatesAutoresizingMaskIntoConstraints = false
        goalDropdown.translatesAutoresizingMaskIntoConstraints = false
        
        [backButton, navTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            customNavBar.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
            
            descriptionLabel.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 32),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 관심사
            interestTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            interestTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            interestSelectButton.topAnchor.constraint(equalTo: interestTitleLabel.bottomAnchor, constant: 8),
            interestSelectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            interestSelectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            interestSelectButton.heightAnchor.constraint(equalToConstant: 55),
            
            // 세부 관심사
            detailInterestTitleLabel.topAnchor.constraint(equalTo: interestSelectButton.bottomAnchor, constant: 24),
            detailInterestTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            detailInterestSelectButton.topAnchor.constraint(equalTo: detailInterestTitleLabel.bottomAnchor, constant: 8),
            detailInterestSelectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailInterestSelectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailInterestSelectButton.heightAnchor.constraint(equalToConstant: 55),
            
            // 목표
            goalTitleLabel.topAnchor.constraint(equalTo: detailInterestSelectButton.bottomAnchor, constant: 24),
            goalTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            goalSelectButton.topAnchor.constraint(equalTo: goalTitleLabel.bottomAnchor, constant: 8),
            goalSelectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            goalSelectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goalSelectButton.heightAnchor.constraint(equalToConstant: 55),
            
            goalWarningLabel.topAnchor.constraint(equalTo: goalSelectButton.bottomAnchor, constant: 8),
            goalWarningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            // Dropdowns
            interestDropdown.topAnchor.constraint(equalTo: interestSelectButton.bottomAnchor, constant: 4),
            interestDropdown.leadingAnchor.constraint(equalTo: interestSelectButton.leadingAnchor),
            interestDropdown.trailingAnchor.constraint(equalTo: interestSelectButton.trailingAnchor),
            interestDropdown.heightAnchor.constraint(equalToConstant: 216),
            
            detailInterestDropdown.topAnchor.constraint(equalTo: detailInterestSelectButton.bottomAnchor, constant: 4),
            detailInterestDropdown.leadingAnchor.constraint(equalTo: detailInterestSelectButton.leadingAnchor),
            detailInterestDropdown.trailingAnchor.constraint(equalTo: detailInterestSelectButton.trailingAnchor),
            detailInterestDropdown.heightAnchor.constraint(equalToConstant: 216),
            
            goalDropdown.topAnchor.constraint(equalTo: goalSelectButton.bottomAnchor, constant: 4),
            goalDropdown.leadingAnchor.constraint(equalTo: goalSelectButton.leadingAnchor),
            goalDropdown.trailingAnchor.constraint(equalTo: goalSelectButton.trailingAnchor),
            goalDropdown.heightAnchor.constraint(equalToConstant: 216),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 56),
            completeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
    
    private func bind() {
        // Back Button
        backButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                if owner.viewModel.isModified() {
                    // 변경사항이 있다면 얼럿 표시
                    owner.showCancelAlert()
                } else {
                    // 변경사항이 없다면 바로 뒤로가기
                    owner.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        let input = InterestEditViewModel.Input(
            interestButtonTapped: interestSelectButton.rx.tap.asObservable(),
            detailInterestButtonTapped: detailInterestSelectButton.rx.tap.asObservable(),
            goalButtonTapped: goalSelectButton.rx.tap.asObservable(),
            interestSelected: interestDropdown.itemSelected.asObservable(),
            detailInterestSelected: detailInterestDropdown.itemSelected.asObservable(),
            goalSelected: goalDropdown.itemSelected.asObservable(),
            completeButtonTapped: completeButton.rx.tap.asObservable(),
            foreignLanguageInput: foreignLanguageInputRelay.asObservable(),
            goalInputText: goalInputTextRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // Interest Binding
        Driver.combineLatest(output.interestList, output.selectedInterestId)
            .drive(with: self, onNext: { owner, data in
                owner.interestDropdown.bind(items: data.0, selectedId: data.1)
            })
            .disposed(by: disposeBag)
        
        Driver.combineLatest(output.detailInterestList, output.selectedDetailInterestId)
            .drive(with: self, onNext: { owner, data in
                owner.detailInterestDropdown.bind(items: data.0, selectedId: data.1)
            })
            .disposed(by: disposeBag)
        
        Driver.combineLatest(output.goalList, output.selectedGoalId)
            .drive(with: self, onNext: { owner, data in
                owner.goalDropdown.bind(items: data.0, selectedId: data.1)
            })
            .disposed(by: disposeBag)
        
        // 관심사 선택 상태 업데이트
        output.currentInterestName
            .drive(with: self, onNext: { owner, name in
                let title = name ?? "관심사 선택"
                let color: UIColor = name != nil ? .cta : .neutral800
                
                owner.interestSelectButton.setAttributedTitle(
                    NSAttributedString(
                        string: title,
                        attributes: [.font: Typography.body1.font, .foregroundColor: color]
                    ),
                    for: .normal
                )
                
                if name != nil {
                    owner.interestDropdown.isHidden = true
                    owner.updateDropdownState(
                        button: owner.interestSelectButton,
                        arrow: owner.interestArrowImageView,
                        isOpen: false
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // 세부 관심사 선택 상태 업데이트
        output.currentDetailInterestName
            .drive(with: self, onNext: { owner, name in
                let title = name ?? "세부 관심사 선택"
                let color: UIColor = name != nil ? .cta : .neutral800
                
                owner.detailInterestSelectButton.setAttributedTitle(
                    NSAttributedString(
                        string: title,
                        attributes: [.font: Typography.body1.font, .foregroundColor: color]
                    ),
                    for: .normal
                )
                
                if name != nil {
                    owner.detailInterestDropdown.isHidden = true
                    owner.updateDropdownState(
                        button: owner.detailInterestSelectButton,
                        arrow: owner.detailInterestArrowImageView,
                        isOpen: false
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // 목표 선택 상태 업데이트
        output.currentGoalName
            .drive(with: self, onNext: { owner, name in
                let title = name ?? "목표 선택"
                let color: UIColor = name != nil ? .cta : .neutral800
                
                owner.goalSelectButton.setAttributedTitle(
                    NSAttributedString(
                        string: title,
                        attributes: [.font: Typography.body1.font, .foregroundColor: color]
                    ),
                    for: .normal
                )
                
                if name != nil {
                    owner.goalDropdown.isHidden = true
                    owner.updateDropdownState(
                        button: owner.goalSelectButton,
                        arrow: owner.goalArrowImageView,
                        isOpen: false
                    )
                }
            })
            .disposed(by: disposeBag)
        
        // 버튼 탭 시 드롭다운 토글
        interestSelectButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.interestDropdown.isHidden.toggle()
                owner.detailInterestDropdown.isHidden = true
                owner.goalDropdown.isHidden = true
                owner.view.endEditing(true)
                
                let isOpen = !owner.interestDropdown.isHidden
                owner.updateDropdownState(
                    button: owner.interestSelectButton,
                    arrow: owner.interestArrowImageView,
                    isOpen: isOpen
                )
            })
            .disposed(by: disposeBag)
        
        detailInterestSelectButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                if owner.interestSelectButton.currentAttributedTitle?.string == "관심사 선택" { return }
                
                owner.detailInterestDropdown.isHidden.toggle()
                owner.interestDropdown.isHidden = true
                owner.goalDropdown.isHidden = true
                owner.view.endEditing(true)
                
                let isOpen = !owner.detailInterestDropdown.isHidden
                owner.updateDropdownState(
                    button: owner.detailInterestSelectButton,
                    arrow: owner.detailInterestArrowImageView,
                    isOpen: isOpen
                )
            })
            .disposed(by: disposeBag)
        
        goalSelectButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                if owner.detailInterestSelectButton.currentAttributedTitle?.string == "세부 관심사 선택" { return }
                
                owner.goalDropdown.isHidden.toggle()
                owner.interestDropdown.isHidden = true
                owner.detailInterestDropdown.isHidden = true
                owner.view.endEditing(true)
                
                let isOpen = !owner.goalDropdown.isHidden
                owner.updateDropdownState(
                    button: owner.goalSelectButton,
                    arrow: owner.goalArrowImageView,
                    isOpen: isOpen
                )
            })
            .disposed(by: disposeBag)
        
        // 드롭다운 닫힐 때 원래 상태로 복귀
        interestDropdown.rx.observe(Bool.self, "isHidden")
            .compactMap { $0 }
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateDropdownState(
                    button: self.interestSelectButton,
                    arrow: self.interestArrowImageView,
                    isOpen: false
                )
            })
            .disposed(by: disposeBag)
        
        detailInterestDropdown.rx.observe(Bool.self, "isHidden")
            .compactMap { $0 }
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateDropdownState(
                    button: self.detailInterestSelectButton,
                    arrow: self.detailInterestArrowImageView,
                    isOpen: false
                )
            })
            .disposed(by: disposeBag)
        
        goalDropdown.rx.observe(Bool.self, "isHidden")
            .compactMap { $0 }
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateDropdownState(
                    button: self.goalSelectButton,
                    arrow: self.goalArrowImageView,
                    isOpen: false
                )
            })
            .disposed(by: disposeBag)
        
        output.showLanguageInputBottomSheet
            .emit(with: self, onNext: { owner, _ in
                owner.showForeignLanguageInputBottomSheet()
            })
            .disposed(by: disposeBag)
        
        output.showGoalInputBottomSheet
            .emit(with: self) { owner, text in
                owner.showGoalInputSheet(initialText: text)
            }
            .disposed(by: disposeBag)
        
        output.goalValidationSuccess
            .emit(with: self) { owner, _ in
                owner.currentGoalBottomSheet?.validationSuccess.accept(())
            }
            .disposed(by: disposeBag)
        
        // 4. 목표 검증 실패 -> 에러 메시지 전달
        output.goalValidationFailed
            .emit(with: self) { owner, msg in
                owner.currentGoalBottomSheet?.validationFailed.accept(msg)
            }
            .disposed(by: disposeBag)
        
        // 5. 3회 실패 락 팝업
        output.showLockAlert
            .emit(with: self) { owner, _ in
                let alert = CustomAlertViewController() // 기존 CustomAlert 사용
                alert.modalPresentationStyle = .overFullScreen
                alert.modalTransitionStyle = .crossDissolve
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        // 6. 타이머 메시지 표시
        output.goalLockTimerMessage
            .drive(with: self) { owner, msg in
                if let message = msg {
                    owner.goalWarningLabel.text = message
                    owner.goalWarningLabel.isHidden = false
                    // 락 상태에서는 드롭다운 닫기 & 아이콘 상태 변경
                    owner.goalDropdown.isHidden = true
                    owner.updateDropdownState(button: owner.goalSelectButton, arrow: owner.goalArrowImageView, isOpen: false)
                } else {
                    owner.goalWarningLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        
        // 완료 버튼 활성화 상태
        output.isCompleteEnabled
            .drive(with: self, onNext: { owner, isEnabled in
                owner.completeButton.isEnabled = isEnabled
                owner.completeButton.backgroundColor = isEnabled ? .cta : .neutral200
            })
            .disposed(by: disposeBag)
        
        // 목표 버튼 활성화/비활성화 처리
        output.isGoalButtonEnabled
            .drive(with: self, onNext: { owner, isEnabled in
                owner.goalSelectButton.isEnabled = isEnabled
                
                if isEnabled {
                    // 활성화 스타일 (흰색 배경)
                    owner.goalSelectButton.backgroundColor = .white
                    owner.goalSelectButton.layer.borderColor = UIColor.neutral200.cgColor
                    owner.goalArrowImageView.isHidden = false
                } else {
                    // 비활성화 스타일 (회색 배경)
                    owner.goalSelectButton.backgroundColor = .neutral50
                    owner.goalSelectButton.layer.borderColor = UIColor.neutral100.cgColor
                    owner.goalArrowImageView.isHidden = true
                    
                }
            })
            .disposed(by: disposeBag)
        
        // 최종 성공 처리
        output.updateSuccess
            .emit(with: self, onNext: { owner, _ in
                owner.view.endEditing(true)
                
                // 1. 무엇이 변경되었는지 확인 (메시지 분기 처리)
                let saved = TokenStorageService.shared.getCurationData()
                let currentInterestId = owner.viewModel.selectedInterestRelay.value?.id
                let currentDetailId = owner.viewModel.selectedDetailInterestRelay.value?.id
                let currentGoalId = owner.viewModel.selectedGoalRelay.value?.id
                
                let isInterestChanged = (currentInterestId != saved?.interest?.id) || (currentDetailId != saved?.interestDetail?.id)
                let isGoalChanged = currentGoalId != saved?.goal?.id
                
                var message = " 관심사 수정이 완료되었어요"
                
                if isInterestChanged && isGoalChanged {
                    message = " 관심사 및 목표가 변경되었어요"
                } else if isInterestChanged {
                    message = " 관심사 변경이 완료되었어요"
                } else if isGoalChanged {
                    message = " 목표 변경이 완료되었어요"
                }
                
                // 2. 토스트 띄우기
                owner.showToast(message: message)
                
                // 3. 1.2초 뒤에 Pop (토스트가 떠있는 동안 잠시 대기)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                    owner.navigationController?.popViewController(animated: true)
//                }
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(with: self) { owner, message in
                owner.showToast(message: message) // 또는 Alert
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(with: self) { owner, isLoading in
                owner.completeButton.isEnabled = !isLoading
                // owner.activityIndicator.isHidden = !isLoading (필요 시)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    private func updateDropdownState(button: UIButton, arrow: UIImageView, isOpen: Bool) {
        let upImage = UIImage(named: "chevron_top")?.withRenderingMode(.alwaysTemplate)
        let downImage = UIImage(named: "chevron_bottom")?.withRenderingMode(.alwaysTemplate)
        
        if isOpen {
            button.layer.borderColor = UIColor.cta.cgColor
            button.layer.borderWidth = 1
            arrow.image = upImage
            arrow.tintColor = .cta
        } else {
            button.layer.borderColor = UIColor.neutral200.cgColor
            button.layer.borderWidth = 1
            arrow.image = downImage
            arrow.tintColor = .neutral800
        }
    }
    
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
        
        alert.onConfirm = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.present(alert, animated: false)
    }
    
    @objc private func dismissKeyboard() {
        if !interestDropdown.isHidden {
            interestDropdown.isHidden = true
            updateDropdownState(button: interestSelectButton, arrow: interestArrowImageView, isOpen: false)
        }
        if !detailInterestDropdown.isHidden {
            detailInterestDropdown.isHidden = true
            updateDropdownState(button: detailInterestSelectButton, arrow: detailInterestArrowImageView, isOpen: false)
        }
        if !goalDropdown.isHidden {
            goalDropdown.isHidden = true
            updateDropdownState(button: goalSelectButton, arrow: goalArrowImageView, isOpen: false)
        }
        view.endEditing(true)
    }
    
    private func showForeignLanguageInputBottomSheet() {
        let bottomSheetViewModel = ForeignLanguageInputBottomSheetViewModel()
        let bottomSheetVC = ForeignLanguageInputBottomSheet(
            viewModel: bottomSheetViewModel,
            type: .edit
        )
        
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.modalTransitionStyle = .crossDissolve
        
        // 바텀시트에서 '다음' 버튼 누르면 실행될 콜백
        bottomSheetVC.onFinish = { [weak self] inputText in
            // ViewModel로 텍스트 전달
            self?.foreignLanguageInputRelay.accept(inputText)
            
            // UI 업데이트: "세부 관심사 선택" 버튼을 사용자가 입력한 텍스트로 즉시 변경하고 싶다면 여기서 처리해도 되지만,
            // ViewModel의 currentDetailInterestName Driver가 자동으로 처리하도록 해두었습니다.
        }
        
        self.present(bottomSheetVC, animated: true)
    }
    
    private func showGoalInputSheet(initialText: String? = nil) {
        let vc = GoalInputBottomSheet()
        vc.modalPresentationStyle = .overFullScreen
        
        vc.initialText = initialText
        
        // 입력 완료 시 VM으로 전달
        vc.onNextTapped = { [weak self] text in
            self?.goalInputTextRelay.accept(text)
        }
        
        self.currentGoalBottomSheet = vc
        present(vc, animated: true)
    }
    
    private func showToast(message: String) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 144/255, green: 149/255, blue: 158/255, alpha: 1.0)
        toastContainer.layer.cornerRadius = 27
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: message)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: .iconSmallCheck)
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
        
        // 1. 나타나는 애니메이션
        toastContainer.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toastContainer.alpha = 1
        } completion: { _ in
            // 2. 일정 시간 대기 후 사라지는 애니메이션
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0
            }) { _ in
                // 3. 완전히 사라지면 뷰 계층에서 제거
                toastContainer.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension InterestEditViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton || touch.view?.superview is UITableViewCell {
            return false
        }
        return true
    }
}
