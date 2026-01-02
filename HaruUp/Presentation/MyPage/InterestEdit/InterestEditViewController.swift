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
        label.setStyle(Typography.body2, text: "관심사를 수정해도 캐릭터의 성장도는 유지돼요.")
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
        let initialTitle = TokenStorageService.shared.getCurationData()?.interest?.name ?? "관심사 선택"
        let titleColor: UIColor = TokenStorageService.shared.getCurationData()?.interest != nil ? .cta : .neutral800
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
        let initialTitle = TokenStorageService.shared.getCurationData()?.interestDetail?.name ?? "세부 관심사 선택"
        let titleColor: UIColor = TokenStorageService.shared.getCurationData()?.interestDetail != nil ? .cta : .neutral800
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
        let initialTitle = TokenStorageService.shared.getCurationData()?.goal?.name ?? "목표 선택"
        let titleColor: UIColor = TokenStorageService.shared.getCurationData()?.goal != nil ? .cta : .neutral800
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
            
            // Dropdowns
            interestDropdown.topAnchor.constraint(equalTo: interestSelectButton.bottomAnchor, constant: 4),
            interestDropdown.leadingAnchor.constraint(equalTo: interestSelectButton.leadingAnchor),
            interestDropdown.trailingAnchor.constraint(equalTo: interestSelectButton.trailingAnchor),
            interestDropdown.heightAnchor.constraint(equalToConstant: 200),
            
            detailInterestDropdown.topAnchor.constraint(equalTo: detailInterestSelectButton.bottomAnchor, constant: 4),
            detailInterestDropdown.leadingAnchor.constraint(equalTo: detailInterestSelectButton.leadingAnchor),
            detailInterestDropdown.trailingAnchor.constraint(equalTo: detailInterestSelectButton.trailingAnchor),
            detailInterestDropdown.heightAnchor.constraint(equalToConstant: 200),
            
            goalDropdown.topAnchor.constraint(equalTo: goalSelectButton.bottomAnchor, constant: 4),
            goalDropdown.leadingAnchor.constraint(equalTo: goalSelectButton.leadingAnchor),
            goalDropdown.trailingAnchor.constraint(equalTo: goalSelectButton.trailingAnchor),
            goalDropdown.heightAnchor.constraint(equalToConstant: 200),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 56),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func bind() {
        // Back Button
        backButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.showCancelAlert()
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
            foreignLanguageInput: foreignLanguageInputRelay.asObservable()
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
        
        // 완료 버튼 활성화 상태
        output.isCompleteEnabled
            .drive(with: self, onNext: { owner, isEnabled in
                owner.completeButton.isEnabled = isEnabled
                owner.completeButton.backgroundColor = isEnabled ? .cta : .neutral200
            })
            .disposed(by: disposeBag)
        
        // 최종 성공 처리
        output.updateSuccess
            .emit(with: self, onNext: { owner, _ in
                owner.view.endEditing(true)
                owner.showToast(message: " 관심사 수정이 완료되었어요")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    owner.navigationController?.popViewController(animated: true)
                }
            })
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
        let bottomSheetVC = ForeignLanguageInputBottomSheet(viewModel: bottomSheetViewModel)
        
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
        
        toastContainer.alpha = 0
        UIView.animate(withDuration: 0.3) { toastContainer.alpha = 1 }
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
