//
//  GoalInputBottomSheet.swift
//  HaruUp
//
//  Created by 하다현 on 1/2/26.
//

//
//  GoalInputBottomSheet.swift
//  HaruUp
//
//  Created by 하다현 on 1/2/26.
//

import UIKit
import RxSwift
import RxCocoa

class GoalInputBottomSheet: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    // ViewModel로 입력값 전달
    var onNextTapped: ((String) -> Void)?
    
    // 외부(ViewModel)에서 제어할 Subjects
    let validationSuccess = PublishRelay<Void>()
    let validationFailed = PublishRelay<String>()

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
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2~20자로 입력해주세요."
        tf.borderStyle = .none
        tf.font = UIFont.pretendard(size: 16, weight: .medium)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let textFieldContainer: UIView = { /* ... (디자인 동일) ... */
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let textFieldBottomLine: UIView = { /* ... */
        let view = UIView()
        view.backgroundColor = UIColor.primaryBlue700.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboard()
        bind()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textField.becomeFirstResponder()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // ... (addSubview 및 AutoLayout 설정 - ForeignLanguageInputBottomSheet 참조) ...
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textFieldContainer)
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(textFieldBottomLine)
        containerView.addSubview(warningLabel)
        containerView.addSubview(nextButton)
        
        // 간략화된 Layout (실제 코드에 맞게 조정 필요)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            textFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textFieldContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            textFieldContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 50),
            
            textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -10),
            
            textFieldBottomLine.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textFieldBottomLine.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            textFieldBottomLine.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            textFieldBottomLine.heightAnchor.constraint(equalToConstant: 2),
            
            warningLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 8),
            warningLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
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
    
    private func bind() {
        // 입력값 길이 체크 (UI 버튼 활성화용)
        textField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespaces).count }
            .map { $0 >= 2 && $0 <= 20 }
            .bind(with: self) { owner, isValid in
                let img = isValid ? "next_btn_blue" : "next_btn_gray"
                owner.nextButton.setImage(UIImage(named: img), for: .normal)
            }
            .disposed(by: disposeBag)
        
        // 텍스트 변경 시 경고 숨김
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.warningLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 -> ViewModel로 텍스트 전달
        nextButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .bind(with: self) { owner, text in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                if trimmed.count < 2 || trimmed.count > 20 { return }
                owner.onNextTapped?(trimmed)
            }
            .disposed(by: disposeBag)
        
        // 검증 성공 시 닫기
        validationSuccess
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 검증 실패 시 에러 표시
        validationFailed
            .bind(with: self) { owner, msg in
                owner.warningLabel.text = msg
                owner.warningLabel.isHidden = false
                owner.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardShow(_ noti: Notification) {
        guard let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraint?.constant = -frame.height + 30
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
