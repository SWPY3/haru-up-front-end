//
//  GoalInputBottomSheet.swift
//  HaruUp
//
//  Created by 하다현 on 1/2/26.
//

import UIKit
import RxSwift
import RxCocoa

final class GoalInputBottomSheet: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    // ViewModel로 입력값 전달
    var onNextTapped: ((String) -> Void)?
    
    // 외부(ViewModel)에서 제어할 Subjects
    let validationSuccess = PublishRelay<Void>()
    let validationFailed = PublishRelay<String>()
    
    // MARK: - UI Components
    private let keyboardBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "원하는 목표를 입력해주세요.")
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2~20자로 입력해주세요."
        tf.borderStyle = .none
        tf.textColor = .black
        tf.font = UIFont.pretendard(size: 16, weight: .medium)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // ✅ [추가] 클리어 버튼
    private let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_x.png"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let textFieldBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.primaryBlue700.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ✅ [추가] 글자 수 카운트 라벨
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption3, text: "0/20")
        label.textColor = .neutral400
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ✅ [추가] 경고 라벨 (2자 이상 입력 등)
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "") // 초기 텍스트 비움
        label.textColor = .secondaryRed200
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next_btn_gray.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var inputBottomSheetBottomConstraint: NSLayoutConstraint?
    private var nextButtonBottomConstraint: NSLayoutConstraint?
    private var keyboardBackgroundHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        setupTapGestures()
        bind()
        
        // 20자 제한을 위한 델리게이트 설정
        textField.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textField.becomeFirstResponder()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(keyboardBackgroundView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.addSubview(textFieldContainer)
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(clearButton) // 추가
        textFieldContainer.addSubview(textFieldBottomLine)
        
        containerView.addSubview(textCountLabel) // 추가
        containerView.addSubview(warningLabel)   // 추가
        containerView.addSubview(nextButton)
        
        // 키보드 배경 제약조건 설정
        NSLayoutConstraint.activate([
            keyboardBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        keyboardBackgroundHeightConstraint = keyboardBackgroundView.heightAnchor.constraint(equalToConstant: 0)
        keyboardBackgroundHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 330), // 높이 약간 증가
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            textFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textFieldContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            textFieldContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // 텍스트필드 배치 (오른쪽에 클리어버튼 자리 확보)
            textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            
            // 클리어 버튼 배치
            clearButton.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -10),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24),
            
            textFieldBottomLine.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textFieldBottomLine.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            textFieldBottomLine.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            textFieldBottomLine.heightAnchor.constraint(equalToConstant: 2),
            
            // 글자 수 카운트 (오른쪽 아래)
            textCountLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 8),
            textCountLabel.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            
            // 경고 메시지 (왼쪽 아래)
            warningLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 8),
            warningLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            warningLabel.trailingAnchor.constraint(lessThanOrEqualTo: textCountLabel.leadingAnchor, constant: -10),
            
            nextButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // 동적 제약조건 설정 (Bottom Constraints)
        inputBottomSheetBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputBottomSheetBottomConstraint?.isActive = true
        
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        nextButtonBottomConstraint?.isActive = true
    }
    
    private func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        
        // containerView 영역 밖을 탭한 경우에만 닫기
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        } else {
            // containerView 내부를 탭한 경우 키보드만 내리기
            view.endEditing(true)
        }
    }
    
    // MARK: - Bindings
    private func bind() {
        
        // 1. 클리어 버튼 동작
        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.textField.text = ""
                self?.textField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        // 2. 텍스트 입력 처리 (글자수, 버튼상태, 경고숨김)
        let textObservable = textField.rx.text.orEmpty.asDriver()
        
        // 빈 값일 때 클리어버튼 숨김
        textObservable
            .map { $0.isEmpty }
            .drive(clearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 글자 수 업데이트 (0/20)
        textObservable
            .map { "\($0.count)/20" }
            .drive(onNext: { [weak self] countText in
                self?.textCountLabel.setStyle(Typography.caption3, text: countText)
            })
            .disposed(by: disposeBag)
        
        // 유효성 검사 (길이 체크) -> 버튼 색상 변경
        textObservable
            .map { $0.trimmingCharacters(in: .whitespaces).count }
            .map { $0 >= 2 && $0 <= 20 }
            .drive(onNext: { [weak self] isValid in
                let img = isValid ? "next_btn_blue" : "next_btn_gray"
                self?.nextButton.setImage(UIImage(named: img), for: .normal)
                
                // 유효한 길이면 경고 숨김
                if isValid {
                    self?.warningLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // 3. 포커스 애니메이션 (밑줄 색상)
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.textFieldBottomLine.backgroundColor = .systemBlue
                }
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.textFieldBottomLine.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
                }
            })
            .disposed(by: disposeBag)
        
        // 4. 다음 버튼 탭 로직
        nextButton.rx.tap
            .asDriver()
            .withLatestFrom(textObservable)
            .drive(onNext: { [weak self] text in
                guard let self = self else { return }
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                
                // [검사 1] 길이 부족 시 경고 표시
                if trimmed.count < 2 {
                    self.warningLabel.setStyle(Typography.body4, text: "*2자 이상으로 입력해주세요.")
                    self.warningLabel.isHidden = false
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    return
                }
                
                // 길이 통과 시 ViewModel로 전달
                self.onNextTapped?(trimmed)
            })
            .disposed(by: disposeBag)
        
        // 5. 외부(ViewModel) 검증 결과 처리
        validationSuccess
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        validationFailed
            .bind(with: self) { owner, msg in
                owner.warningLabel.setStyle(Typography.body4, text: msg)
                owner.warningLabel.isHidden = false
                owner.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Keyboard UI Logic (Reference와 동일하게 수정)
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let overlap: CGFloat = 30 // 바텀시트와 키보드가 겹치는 정도
        
        // 1. 키보드 뒤 배경 뷰 표시 및 높이 설정
        keyboardBackgroundView.isHidden = false
        keyboardBackgroundHeightConstraint?.constant = keyboardHeight
        
        // 2. 바텀시트를 키보드 위로 이동 (overlap 만큼 살짝 덮이게)
        inputBottomSheetBottomConstraint?.constant = -(keyboardHeight - overlap)
        
        // 3. 버튼 위치 조정 (필요 시)
        nextButtonBottomConstraint?.constant = -40
        
        // 4. 애니메이션 적용
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        // 1. 배경 숨기기
        keyboardBackgroundView.isHidden = true
        keyboardBackgroundHeightConstraint?.constant = 0
        
        // 2. 바텀시트 원위치
        inputBottomSheetBottomConstraint?.constant = 0
        nextButtonBottomConstraint?.constant = -10
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate (20자 제한)
extension GoalInputBottomSheet: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 20
    }
}
