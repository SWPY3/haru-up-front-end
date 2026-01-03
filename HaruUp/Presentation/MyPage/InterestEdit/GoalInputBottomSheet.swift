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
    
    private var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboard()
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
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.addSubview(textFieldContainer)
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(clearButton) // 추가
        textFieldContainer.addSubview(textFieldBottomLine)
        
        containerView.addSubview(textCountLabel) // 추가
        containerView.addSubview(warningLabel)   // 추가
        containerView.addSubview(nextButton)
        
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
        
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bgTap))
        view.addGestureRecognizer(tap)
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
    
    // MARK: - Keyboard & Gestures
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardShow(_ noti: Notification) {
        guard let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        // 키보드 높이만큼 바텀시트를 위로 올림
        bottomConstraint?.constant = -frame.height + 20 // 약간의 여유값
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    @objc func keyboardHide(_ noti: Notification) {
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    @objc func bgTap(_ gesture: UITapGestureRecognizer) {
        let loc = gesture.location(in: view)
        if !containerView.frame.contains(loc) { dismiss(animated: true) }
        else { view.endEditing(true) }
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
