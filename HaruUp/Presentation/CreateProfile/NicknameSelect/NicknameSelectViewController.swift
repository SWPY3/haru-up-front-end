//
//  NicknameSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit
import RxSwift
import RxCocoa



class NicknameSelectViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let selectedCharacter: Int
    private let viewModel: CreateProfileViewModel
    
    
    var onFinish: ((Int, String) -> Void)? // 캐릭터 인덱스, 닉네임
    
    private var currentNickname: String = ""
    
    
    private var nextButtonBottomConstraint: NSLayoutConstraint?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임을 지어주세요"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "하루업에서 불리고 싶은 이름을 지어주세요."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        return label
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "홍길동"
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        return tf
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let textFieldBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        return view
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "2~10자로 입력해주세요."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("다음", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    // MARK: - Init
    init(selectedCharacter: Int, viewModel: CreateProfileViewModel) {
        self.selectedCharacter = selectedCharacter
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        bindUI()
        setupKeyboardObservers()
        setupTapGesture()
        
        // 키보드 자동으로 올라오게
        textField.becomeFirstResponder()
    }
    
    // 화면 탭 시 키보드 내리기
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    // 키보드가 올라올 때
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        // nextButton을 키보드 위로 이동 (safeArea bottom 대신 키보드 높이만큼)
        nextButtonBottomConstraint?.constant = -(keyboardHeight + 20)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
        
    // 키보드가 내려갈 때
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        // nextButton을 원래 위치로 복원
        nextButtonBottomConstraint?.constant = -20
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    // MARK: - Setup UI
        
    private func setupUI() {
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(textFieldBottomLine)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(textFieldContainer)
        view.addSubview(warningLabel)
        view.addSubview(nextButton)
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 60,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        subtitleLabel.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 12,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        textFieldContainer.anchor(
            top: subtitleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 40,
            paddingLeft: 30,
            paddingRight: 30,
            height: 50
        )
        
        textField.anchor(
            top: textFieldContainer.topAnchor,
            left: textFieldContainer.leftAnchor,
            bottom: textFieldContainer.bottomAnchor,
            right: textFieldContainer.rightAnchor,
            paddingLeft: 9,
            paddingRight: 9
            
        )
        
        textFieldBottomLine.anchor(
            left: textFieldContainer.leftAnchor,
            bottom: textFieldContainer.bottomAnchor,
            right: textFieldContainer.rightAnchor,
            height: 2
        )
        
        warningLabel.anchor(
            top: textFieldContainer.bottomAnchor,
            left: view.leftAnchor,
            paddingTop: 8,
            paddingLeft: 30
        )
        
//        nextButton.anchor(
//            left: view.leftAnchor,
//            bottom: view.safeAreaLayoutGuide.bottomAnchor,
//            right: view.rightAnchor,
//            paddingLeft: 20,
//            paddingBottom: 20,
//            paddingRight: 20,
//            height: 56
//        )
        
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -20
        )
        nextButtonBottomConstraint?.isActive = true
    }
    
    // MARK: - Bind UI
    
    private func bindUI() {
        
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                print("🔵 포커스 들어옴")
                UIView.animate(withDuration: 0.3) {
                    self?.textFieldBottomLine.backgroundColor = .systemBlue
                }
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                print("🔵 포커스 나감")
                UIView.animate(withDuration: 0.3) {
                    self?.textFieldBottomLine.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
                }
            })
            .disposed(by: disposeBag)
        
        // 현재 닉네임 저장
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.currentNickname = text.trimmingCharacters(in: .whitespaces)
            })
            .disposed(by: disposeBag)
        
        // 버튼 활성화 조건( 2글자 이상)
        let isValidNickname = textField.rx.text.orEmpty
            .map { text in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                return trimmed.count >= 2 && trimmed.count <= 10
            }
            .share(replay: 1)
        
        isValidNickname
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        isValidNickname
            .subscribe(onNext: { [weak self] isValid in
                self?.nextButton.backgroundColor = isValid ? UIColor.systemBlue : UIColor.gray
            })
            .disposed(by: disposeBag)
        
        
        textField.rx.text.orEmpty
            .map { text in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                let count = trimmed.count
                // 텍스트가 있으면서 2자 미만이거나 10자 초과인 경우
                return (count > 0 && (count < 2 || count > 10))
            }
            .subscribe(onNext: { [weak self] shouldShowWarning in
                UIView.animate(withDuration: 0.2) {
                    self?.warningLabel.text = "2~10자로 입력해주세요."
                    self?.warningLabel.textColor = shouldShowWarning ? .systemRed : .gray
                }
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count >= 2 }
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                self.onFinish?(self.selectedCharacter, nickname)
                
                self.viewModel.submitProfile(characterIndex: self.selectedCharacter, nickname: nickname)
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                // 빈 텍스트필드인 경우
                if nickname.isEmpty {
                    UIView.animate(withDuration: 0.2) {
                        self.warningLabel.text = "*닉네임을 입력해주세요."
                        self.warningLabel.textColor = .systemRed
                    }
                    return
                }
                
                // 2자 미만 또는 10자 초과인 경우
                if nickname.count < 2 || nickname.count > 10 {
                    UIView.animate(withDuration: 0.2) {
                        self.warningLabel.text = "*2~10자로 입력해주세요."
                        self.warningLabel.textColor = .systemRed
                    }
                    return
                }
                
                // ViewModel Output 바인딩
                viewModel.showDuplicateNicknameAlert
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        let alert = UIAlertController(
                            title: "닉네임 중복",
                            message: "이미 사용 중인 닉네임입니다.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                            // 버튼 비활성화
                            self?.nextButton.isEnabled = false
                            self?.nextButton.backgroundColor = .systemGray3
                            self?.nextButton.alpha = 0.5
                        })
                        self?.present(alert, animated: true)
                    })
                    .disposed(by: disposeBag)
                
                viewModel.errorMessage
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] message in
                        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self?.present(alert, animated: true)
                    })
                    .disposed(by: disposeBag)
                
                viewModel.shouldComplete
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        print("shouldComplete 호출됨")
                    })
                    .disposed(by: disposeBag)
            }
                       
    )}
}
