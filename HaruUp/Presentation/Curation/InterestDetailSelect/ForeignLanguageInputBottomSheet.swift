//
//  ForeignLanguageInputBottomSheet.swift
//  HaruUp
//
//  Created by 하다현 on 12/18/25.
//

import UIKit
import RxSwift
import RxCocoa

class ForeignLanguageInputBottomSheet: UIViewController {
    private let viewModel: ForeignLanguageInputBottomSheetViewModel
    private let disposeBag = DisposeBag()
    
    
    // 완료 콜백
    var onFinish: ((String) -> Void)?
    
    private let languageInputSubject = PublishSubject<String>()
    private var currentLanguageInput: String = ""
    
    private var inputBottomSheetBottomConstraint: NSLayoutConstraint?
    private var nextButtonBottomConstraint: NSLayoutConstraint?
    
    
    private let keyboardBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = .white // 또는 .systemBackground
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
        label.setStyle(Typography.subtitle1, text: "원하는 외국어를 입력해주세요.")
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "프랑스어"
        tf.borderStyle = .none
        tf.font = UIFont.pretendard(size: 16, weight: .medium)
        tf.textColor = .black
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textFieldBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.primaryBlue700.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_x.png"), for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.setStyle(Typography.body4, text: "")
        label.textColor = .secondaryRed200
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next_btn_gray.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let maxHeight: CGFloat = 300
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var keyboardBackgroundBottomConstraint: NSLayoutConstraint?
    private var keyboardBackgroundHeightConstraint: NSLayoutConstraint?
    
    
    init(viewModel: ForeignLanguageInputBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        setupKeyboardObservers()
        setupTapGestures()
        
        // 키보드 자동 올리기
        //        textField.becomeFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textField.becomeFirstResponder()
        }
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
    
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // 키보드가 올라올 때
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let overlap: CGFloat = 30
        
        // 키보드 뒤 배경 뷰 표시 및 크기 설정
        keyboardBackgroundView.isHidden = false
        keyboardBackgroundHeightConstraint?.constant = keyboardHeight
        
        // bottomSheet를 키보드 위로 이동 (safeArea bottom 대신 키보드 높이만큼)
        inputBottomSheetBottomConstraint?.constant = -(keyboardHeight - overlap)
        nextButtonBottomConstraint?.constant = -40
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }
    
    // 키보드가 내려갈 때
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        // 키보드 뒤 배경 뷰 숨기기
        keyboardBackgroundView.isHidden = true
        keyboardBackgroundHeightConstraint?.constant = 0
        
        // bottomSheet를 원래 위치로 복원
        inputBottomSheetBottomConstraint?.constant = 0
        nextButtonBottomConstraint?.constant = -5
        
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
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        view.addSubview(keyboardBackgroundView)
        
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(textFieldBottomLine)
        textFieldContainer.addSubview(clearButton)
        
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textFieldContainer)
        containerView.addSubview(warningLabel)
        containerView.addSubview(nextButton)
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: maxHeight)
        containerViewHeightConstraint?.isActive = true
        
        inputBottomSheetBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                                 constant: 0
        )
        
        inputBottomSheetBottomConstraint?.isActive = true
        
        
        
        keyboardBackgroundBottomConstraint = keyboardBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        keyboardBackgroundHeightConstraint = keyboardBackgroundView.heightAnchor.constraint(equalToConstant: 0)
        
        keyboardBackgroundView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor
        )
        
        keyboardBackgroundBottomConstraint?.isActive = true
        keyboardBackgroundHeightConstraint?.isActive = true
        
        
        containerView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor
        )
        
        titleLabel.anchor(
            top: containerView.topAnchor,
            left: containerView.leftAnchor,
            right: containerView.rightAnchor,
            paddingTop: 50,
            paddingLeft: 24,
            paddingRight: 24
        )
        
        textFieldContainer.anchor(
            top: titleLabel.bottomAnchor,
            left: containerView.leftAnchor,
            right: containerView.rightAnchor,
            paddingTop: 24,
            paddingLeft: 24,
            paddingRight: 24,
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
        
        clearButton.anchor(
            bottom: textField.bottomAnchor,
            right: textFieldContainer.rightAnchor,
            paddingBottom: 10
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
            paddingLeft: 20
        )
        
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                                        constant: -5
        )
        
        nextButtonBottomConstraint?.isActive = true
        
        
        nextButton.anchor(
            left: containerView.leftAnchor,
            right: containerView.rightAnchor,
            paddingLeft: 24,
            paddingRight: 24,
            height: 56
        )
    }
    
    private func bindViewModel() {
        
        textField.rx.text.orEmpty
            .bind(to: languageInputSubject)
            .disposed(by: disposeBag)
        
        let input = ForeignLanguageInputBottomSheetViewModel.Input(
            languageInput: languageInputSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
            )
        let output = viewModel.transform(input: input)
        
        
        // 1. clearButton 표시/숨김
        textField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .subscribe(onNext: { [weak self] hasText in
                UIView.animate(withDuration: 0.2) {
                    self?.clearButton.isHidden = !hasText
                }
            })
            .disposed(by: disposeBag)
        
        // 2. clearButton 탭
        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.textField.text = ""
                self?.textField.sendActions(for: .editingChanged)
                self?.warningLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // 3. 텍스트필드 포커스 상태
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
        
        // 4. 텍스트 입력 시 경고 메시지 숨김
        textField.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.warningLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // 현재 입력 언어 저장
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.currentLanguageInput = text.trimmingCharacters(in: .whitespaces)
            })
            .disposed(by: disposeBag)
        
        // 5. 실시간 글자 수 체크 (2~10자)
        output.isLengthValid
            .drive(onNext: { [weak self] isValid in
                let imageName = isValid ? "next_btn_blue" : "next_btn_gray"
                self?.nextButton.setImage(UIImage(named: imageName), for: .normal)
            })
            .disposed(by: disposeBag)
        
        // 텍스트 여부에 따른 버튼 활성화 제어
        textField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] hasText in
                self?.nextButton.isEnabled = hasText
            })
            .disposed(by: disposeBag)
        
        // 6. 다음 버튼 탭 시 전체 유효성 검사
        output.buttonTapValidation
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.warningLabel.isHidden = true
                    self.warningLabel.text = ""
                    self.dismiss(animated: true) {
                        self.onFinish?(self.currentLanguageInput)
                    }
                    
                case .empty:
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    
                case .tooShort, .tooLong:
                    self.warningLabel.setStyle(Typography.body4, text: "*2~15자로 입력해주세요.")
                    self.warningLabel.isHidden = false
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    
                case .invalidCharacters:
                    self.warningLabel.setStyle(Typography.body4, text: "*한글만 입력해주세요.")
                    self.warningLabel.isHidden = false
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    
                case .incompleteKorean:
                    self.warningLabel.setStyle(Typography.body4, text: "*올바른 형태로 입력해주세요.")
                    self.warningLabel.isHidden = false
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
}
