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
    
    // 직장인 (Selected State Mock)
    private let jobSelectButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("직장인", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal) // Selected Color
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor // Purple/Blue stroke
        
        // Shadow for selected state
        btn.layer.shadowColor = UIColor.systemBlue.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        
        // Arrow Icon
        let img = UIImage(systemName: "chevron.down")
        let imgView = UIImageView(image: img)
        imgView.tintColor = .systemBlue
        imgView.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            imgView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        
        return btn
    }()
    
    private let detailJobTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "세부 직무"
        label.textColor = .darkGray
        return label
    }()
    
    // 디자이너 (Unselected State Mock)
    private let detailJobSelectButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("디자이너", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        let img = UIImage(systemName: "chevron.down")
        let imgView = UIImageView(image: img)
        imgView.tintColor = .lightGray
        imgView.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            imgView.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16)
        ])
        
        return btn
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
        
        var parent = self.parent
        while parent != nil {
            if let tabBar = parent as? MainTabBarController {
                tabBar.setTabBarHidden(true, animated: animated)
                break
            }
            parent = parent?.parent
        }
        
        nicknameTextField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nicknameTextField.becomeFirstResponder()
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
    
    // MARK: - Setup & Bind
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        [customNavBar, nicknameTitleLabel, textFieldContainer, warningLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
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
        completeButtonBottomConstraint = completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        completeButtonBottomConstraint = completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        
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
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 56),
            completeButtonBottomConstraint!
        ])
    }
    
    private func bind() {
        // 1. Back Button Action
        backButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.showCancelAlert()
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
            nicknameInput: nicknameTextField.rx.text.orEmpty.asObservable(), clearButtonTapped: clearButton.rx.tap.asObservable(),
            completeButtonTapped: completeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
    
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
            .emit(with: self, onNext: { owner, _ in
                owner.view.endEditing(true)
                owner.showToast(message: " 닉네임 변경이 완료되었어요")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    owner.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        //        output.initialNickname
        //            .drive(nicknameTextField.rx.text)
        //            .disposed(by: disposeBag)
        //
        //        output.isCompleteEnabled
        //            .drive(with: self, onNext: { owner, isEnabled in
        //                owner.completeButton.isEnabled = isEnabled
        //                owner.completeButton.backgroundColor = isEnabled ? .systemBlue : .lightGray.withAlphaComponent(0.5)
        //            })
        //            .disposed(by: disposeBag)
        //
        
        
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
        
        self.present(alert, animated: false) // custom transition 사용 시 false
    }
    
    // MARK: - Private Helper Methods
    private func handleValidationResult(_ result: ValidationResult) {
        switch result {
        case .success:
            warningLabel.isHidden = true
            // 다음 화면 이동 로직 등 추가
            
        case .empty:
            // Empty일 때는 보통 버튼이 비활성화 되어있겠지만 예외처리
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
//            toastContainer.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -20),
//            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            toastContainer.heightAnchor.constraint(equalToConstant: 54),
//            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
//            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
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

// MARK: - Keyboard Handling Extension
extension ProfileEditViewController: UIGestureRecognizerDelegate {
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        completeButtonBottomConstraint?.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        completeButtonBottomConstraint?.constant = -5
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        
        return true
    }
}
