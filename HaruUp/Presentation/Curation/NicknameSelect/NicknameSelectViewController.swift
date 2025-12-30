//
//  NicknameSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class NicknameSelectViewController: UIViewController {
    
    // MARK: - UI Components
    private let progressBar: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progress = 1.0 / 8.0
        view.tintColor = .cta
        view.trackTintColor = .neutral50
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "닉네임을 지어주세요")
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "하루업에서 불리고 싶은 이름을 적어주세요.")
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
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2~10자의 한글만 입력해주세요."
        tf.setPlaceholder(color: .neutral300)
        tf.font = Typography.body1.font
        tf.borderStyle = .none
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
        view.backgroundColor = .cta
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
        sv.spacing = 42
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
    private let viewModel: NicknameSelectViewModel
    private let disposeBag = DisposeBag()
    private var nextButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    init(viewModel: NicknameSelectViewModel) {
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
        
        self.textField.becomeFirstResponder()
    }
    
    // 화면 탭 시 키보드 내리기
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupLayout() {
        // Add Subviews
        [textField, clearButton, textFieldBottomLine].forEach { textFieldContainer.addSubview($0) }
        [mainStackView, textFieldContainer, warningLabel, nextButton].forEach { view.addSubview($0) }
        
        // Layout Constraints
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        
        NSLayoutConstraint.activate([
            // Main StackView (Progress + Titles)
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
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
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            textField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            
            clearButton.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 24), // 터치 영역 확보 필요 시 조정
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
        
        // 1. Input 생성 (Subject 제거하고 바로 바인딩)
        let input = NicknameSelectViewModel.Input(
            nicknameInput: textField.rx.text.orEmpty.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 2. UI Event Bindings
        
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
            .drive(onNext: { [weak self] _ in
                self?.animateBottomLine()
            })
            .disposed(by: disposeBag)
        
        // 타이핑 시작하면 경고 숨김
        textField.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.warningLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        // 3. Output Bindings
        
        // 길이 유효성 (버튼 색상)
        output.isLengthValid
            .drive(onNext: { [weak self] isValid in
                self?.nextButton.backgroundColor = isValid ? .cta : .neutral200
                self?.nextButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
        
        // 최종 검증 결과 처리
        output.buttonTapValidation
            .drive(onNext: { [weak self] result in
                self?.handleValidationResult(result)
                
                if case .success = result {
                    self?.view.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Helper Methods
    
    // 복잡한 Switch문 분리
    private func handleValidationResult(_ result: ValidationResult) { // Enum 타입 추론
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
        textField.sendActions(for: .editingChanged) // Rx에 '빈 값'임을 알림
        warningLabel.isHidden = true
    }
}

}
