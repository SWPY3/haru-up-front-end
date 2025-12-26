//
//  GoalInputSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

class GoalInputSelectViewController: UIViewController {
    private let viewModel: GoalInputSelectViewModel
    
    private let disposeBag = DisposeBag()
    
    private let goalInputSubject = PublishSubject<String>()
    private var currentGoalInput: String = ""
    
    private var nextButtonBottomConstraint: NSLayoutConstraint?
    
    let curationData: CurationData
    
    // 잘못된 입력 카운트
    private var invalidAttemptCount = 0
    
    // 타이머
    private var countdownTimer: Timer?
    private var remainingSeconds = 0
    
    // 테스트용: API 응답 시뮬레이션
    private var shouldPassValidation = true
    
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron_left.png"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 8.0 / 8.0
        progressBar.tintColor = .primaryBlue700
        progressBar.trackTintColor = .neutral50
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "찾는 목표가 없으신가요?")
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "관심사에 맞는 원하는 목표를 알려주세요.")
        label.textAlignment = .left
        label.textColor = .neutral700
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 35
        return sv
    }()
    
    private let titleLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 12
        return sv
    }()
    
    // 선택된 세부 관심사 안내 라벨
    private let interestDetailTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption2, text: "🥰 선택한 세부 관심사")
        label.textAlignment = .left
        label.textColor = .neutral600
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 선택한 세부 관심사를 담는 파란색 배경 뷰
    private let selectedInterestContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.primaryBlue50
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedInterestDetailLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption1, text: "")
        label.textAlignment = .center
        label.textColor = .primaryBlue700
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2~20자로 입력해주세요."
        tf.font = UIFont.pretendard(size: 16, weight: .medium)
        tf.borderStyle = .none
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
        label.text = "2~20자로 입력해 주세요."
        label.setStyle(Typography.body4, text: "")
        label.textColor = .secondaryRed200
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.caption3, text: "0/20")
        label.textColor = .neutral400
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next_btn_gray.png"), for: .normal)
        button.contentMode = .scaleAspectFit
        //        button.isEnabled = false
        return button
    }()
    
    
    
    
    init(viewModel: GoalInputSelectViewModel, curationData: CurationData) {
        self.viewModel = viewModel
        self.curationData = curationData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        setupUI()
        bindViewModel()
        setupKeyboardObservers()
        setupTapGesture()
        
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
        nextButtonBottomConstraint?.constant = -(keyboardHeight + 0)
        
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
        nextButtonBottomConstraint?.constant = -5
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        
        
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(textFieldBottomLine)
        textFieldContainer.addSubview(clearButton)
        
        view.addSubview(stackView)
        view.addSubview(textFieldContainer)
        view.addSubview(warningLabel)
        view.addSubview(nextButton)
        
        
        stackView.addArrangedSubview(progressBar)
        stackView.addArrangedSubview(titleLabelStackView)
        
        view.addSubview(interestDetailTitleLabel)
        view.addSubview(selectedInterestContainerView)
        view.addSubview(textCountLabel)
        
        selectedInterestContainerView.addSubview(selectedInterestDetailLabel)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        
        
        backButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            paddingTop: 10,
            paddingLeft: 20,
            width: 20,
            height: 20
        )
        
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        progressBar.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        titleLabelStackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        interestDetailTitleLabel.anchor(
            top: titleLabelStackView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 15,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        selectedInterestContainerView.anchor(
            top: interestDetailTitleLabel.bottomAnchor,
            left: view.leftAnchor,
            paddingTop: 4,
            paddingLeft: 20
        )
        
        selectedInterestDetailLabel.anchor(
            top: selectedInterestContainerView.topAnchor,
            left: selectedInterestContainerView.leftAnchor,
            bottom: selectedInterestContainerView.bottomAnchor,
            right: selectedInterestContainerView.rightAnchor,
            paddingTop: 4,
            paddingLeft: 10,
            paddingBottom: 4,
            paddingRight: 10
        )
        
        selectedInterestDetailLabel.setStyle(Typography.caption1, text: "\(curationData.interestDetail?.name ?? "")")
        
        textFieldContainer.anchor(
            top: selectedInterestContainerView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 33,
            paddingLeft: 20,
            paddingRight: 20,
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
        
        textCountLabel.anchor(
            top: textFieldBottomLine.bottomAnchor,
            right: textFieldContainer.rightAnchor,
            paddingTop: 10
        )
        
        warningLabel.anchor(
            top: textFieldContainer.bottomAnchor,
            left: view.leftAnchor,
            paddingTop: 8,
            paddingLeft: 20
        )
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -5
        )
        
        nextButton.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingRight: 20,
            height: 56
        )
        
        nextButtonBottomConstraint?.isActive = true
        
    }
    
    private func bindViewModel() {
        
        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.textField.text = ""
                self?.textField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .subscribe(onNext: { [weak self] hasText in
                UIView.animate(withDuration: 0.2) {
                    self?.clearButton.isHidden = !hasText
                }
            })
            .disposed(by: disposeBag)
        
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
        
        // 실시간 글자 수 카운터 업데이트
                textField.rx.text.orEmpty
                    .subscribe(onNext: { [weak self] text in
                        guard let self = self else { return }
                        
                        let count = text.count
                        self.textCountLabel.setStyle(Typography.caption3, text: "\(count)/20")
                        // goalInputSubject에도 전송 (ViewModel과 동기화)
                        self.goalInputSubject.onNext(text)
                        
//                        print("📝 입력된 텍스트: '\(text)', 길이: \(count)")
                    })
                    .disposed(by: disposeBag)
        
        // 텍스트 입력 시 경고 메시지 숨김 (타이머 작동 중이 아닐 때만)
        textField.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds == 0 {
                    self.warningLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .bind(to: goalInputSubject)
            .disposed(by: disposeBag)
        
        let isValidGoalSubject = PublishSubject<Bool>()
        
        let input = GoalInputSelectViewModel.Input(
            goalInput: goalInputSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable(),
            isValidGoal: isValidGoalSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 실시간 글자 수 체크 (2~20자 사이인지만 확인)
        output.isLengthValid
            .drive(onNext: { [weak self] isValid in
                guard let self = self else { return }
                // 타이머가 작동 중이면 버튼은 항상 비활성화
                if self.remainingSeconds > 0 {
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                } else {
                    let imageName = isValid ? "next_btn_blue" : "next_btn_gray"
                    self.nextButton.setImage(UIImage(named: imageName), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        // 텍스트 여부에 따른 버튼 활성화 제어
        textField.rx.text.orEmpty
            .map { [weak self] text -> Bool in
                guard let self = self else { return false }
                // 타이머 작동 중이면 항상 비활성화
                if self.remainingSeconds > 0 {
                    return false
                }
                return !text.isEmpty
            }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] hasText in
                self?.nextButton.isEnabled = hasText
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 시 전체 유효성 검사 결과
        output.buttonTapValidation
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.warningLabel.text = ""
                    self.warningLabel.isHidden = true
                    self.invalidAttemptCount = 0 // 성공 시 카운트 초기화
                    
                case .empty:
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    
                case .tooShort:
                    self.warningLabel.setStyle(Typography.body4, text: "*2자 이상으로 입력해주세요.")
                    self.warningLabel.isHidden = false
                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    
//                case .tooLong:
//                    self.warningLabel.setStyle(Typography.body4, text: "*20자 이내로 입력해주세요.")
//                    self.warningLabel.isHidden = false
//                    self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    
                case .invalidGoal:
                    self.invalidAttemptCount += 1
                    print("❌ 잘못된 입력 시도: \(self.invalidAttemptCount)회")
                    
                    if self.invalidAttemptCount >= 3 {
                        // 3번 실패 시 팝업 표시
                        self.showLockAlert()
                    } else {
                        self.warningLabel.setStyle(Typography.body4, text: "*세부 관심사와 맞지 않는 목표예요.")
                        self.warningLabel.isHidden = false
                        self.nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // ViewModel에서 유효성 검사 요청이 오면 응답
        output.requestValidation
            .drive(onNext: { [weak self] in
                // 여기서 true/false를 임의로 설정할 수 있습니다
                // 테스트용: false를 주면 항상 실패
                guard let self = self else { return }
                print("🔔 [ViewController] API 유효성 검사 요청 받음")
                
                
                let isValid = self.shouldPassValidation
                
                print("📤 [ViewController] API 응답 전송: \(isValid ? "✅ 성공" : "❌ 실패")")
                isValidGoalSubject.onNext(isValid)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Alert & Timer
    
    // 3번 실패 시 표시되는 팝업
    private func showLockAlert() {
        let alertVC = CustomAlertViewController()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        alertVC.onConfirm = { [weak self] in
            self?.startCountdownTimer()
        }
        
        present(alertVC, animated: true)
    }
    
    // 30분 타이머 시작
    private func startCountdownTimer() {
        remainingSeconds = 30 * 60
        
        nextButton.isEnabled = false
        nextButton.setImage(UIImage(named: "next_btn_gray"), for: .normal)
        textField.isEnabled = false
        
        updateWarningLabelWithTimer()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.remainingSeconds -= 1
            
            if self.remainingSeconds <= 0 {
                self.stopCountdownTimer()
            } else {
                self.updateWarningLabelWithTimer()
            }
        }
    }
    
    // 타이머 중지 및 초기화
    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        remainingSeconds = 0
        invalidAttemptCount = 0
        
        // 버튼 활성화 및 텍스트 입력 허용
        textField.isEnabled = true
        nextButton.isEnabled = true
        
        warningLabel.isHidden = true
        warningLabel.text = ""
    }
    
    // 경고 라벨에 남은 시간 표시
    private func updateWarningLabelWithTimer() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        
        warningLabel.setStyle(Typography.body4, text: String(format: "*%02d분 %02d초 뒤에 입력할 수 있어요.", minutes, seconds))
        warningLabel.isHidden = false
        textField.text = ""
    }
    
}


// MARK: - UITextFieldDelegate
extension GoalInputSelectViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 현재 텍스트
        let currentText = textField.text ?? ""
        
        // 변경될 텍스트 계산
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 20자 제한
        return updatedText.count <= 20
    }
}
