//
//  BirthSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class BirthSelectViewController: UIViewController {
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron_left.png"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progress = 5.0 / 8.0
        view.tintColor = .primaryBlue700
        view.trackTintColor = .neutral50
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "생년월일을 입력해주세요")
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "적절한 미션 추천에 필요해요! 외부에 공개되지 않아요.")
        label.textAlignment = .left
        label.textColor = .neutral700
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "YYYYMMDD"
        tf.setPlaceholder(color: .neutral300)
        tf.font = Typography.body1.font
        tf.borderStyle = .none
        tf.keyboardType = .numberPad
        tf.textColor = .neutral1000
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
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
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    
    // 전체 구성을 담을 메인 스택뷰
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [progressBar, titleStackView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 35
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("다음", for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.backgroundColor = .neutral200
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Properties
    private let viewModel: BirthSelectViewModel
    private let disposeBag = DisposeBag()
    private var nextButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    init(viewModel: BirthSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttributes()
        setupLayout()
        bindViewModel()
        setupKeyboardHandling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - Setup Methods
    private func setupAttributes() {
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupLayout() {
        // Add Subviews
        [textField, clearButton, textFieldBottomLine].forEach { textFieldContainer.addSubview($0) }
        [backButton, mainStackView, textFieldContainer, warningLabel, nextButton].forEach { view.addSubview($0) }
        
        // Layout Constraints
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        
        NSLayoutConstraint.activate([
            // Back Button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Main StackView (Progress + Titles)
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressBar.heightAnchor.constraint(equalToConstant: 6),
            
            // TextField Container
            textFieldContainer.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 40),
            textFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // TextField Internal
            textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 9),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            
            clearButton.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24),
            
            textFieldBottomLine.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            textFieldBottomLine.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            textFieldBottomLine.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            textFieldBottomLine.heightAnchor.constraint(equalToConstant: 2),
            
            // Warning Label
            warningLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 8),
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Next Button
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            nextButtonBottomConstraint!
        ])
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        
        let input = BirthSelectViewModel.Input(
            birthInput: textField.rx.text.orEmpty.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // Back Button
        backButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // Clear Button 동작
        clearButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.resetTextField()
            })
            .disposed(by: disposeBag)
        
        // 텍스트 유무에 따른 ClearButton 표시
        textField.rx.text.orEmpty
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .bind(to: clearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 포커스 애니메이션 (ControlEvent 활용)
        textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
            .asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.animateBottomLine()
            })
            .disposed(by: disposeBag)
        
        // 타이핑 시작하면 경고 숨김
        textField.rx.text.orEmpty
            .skip(1)
            .subscribe(with: self, onNext: { owner, _ in
                owner.warningLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // 길이 유효성 (버튼 색상)
        output.isLengthValid
            .drive(with: self, onNext: { owner, isValid in
                owner.nextButton.backgroundColor = isValid ? .cta : .neutral200
                owner.nextButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
        
        // 최종 검증 결과 처리
        output.buttonTapValidation
            .drive(with: self, onNext: { owner, result in
                owner.handleValidationResult(result)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Helper Methods
    private func handleValidationResult(_ result: BirthValidationResult) {
        switch result {
        case .success:
            warningLabel.isHidden = true
            // 다음 화면 이동 로직
            
        case .empty:
            // 버튼이 비활성화 상태일 것이므로 별도 처리 불필요
            break
            
        case .tooShort, .tooLong, .invalid:
            showWarning("*올바른 생년월일을 입력해주세요.")
        }
    }
    
    private func showWarning(_ text: String) {
        warningLabel.setStyle(Typography.body4, text: text)
        warningLabel.isHidden = false
        
        nextButton.backgroundColor = .neutral200
    }
    
    private func animateBottomLine() {
        let isFocused = textField.isFirstResponder
        UIView.animate(withDuration: 0.3) {
            self.textFieldBottomLine.backgroundColor = isFocused ? .systemBlue : UIColor.primaryBlue700.withAlphaComponent(0.3)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func resetTextField() {
        textField.text = ""
        textField.sendActions(for: .editingChanged)
        warningLabel.isHidden = true
    }
}

// MARK: - Keyboard Handling Extension
extension BirthSelectViewController: UIGestureRecognizerDelegate {
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        nextButtonBottomConstraint?.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom + 10)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        nextButtonBottomConstraint?.constant = -5
        
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
