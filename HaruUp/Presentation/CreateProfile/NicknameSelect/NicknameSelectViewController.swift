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
        tf.placeholder = "2~10자로 입력해주세요"
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
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        bindUI()
        
        // 키보드 자동으로 올라오게
        textField.becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(textFieldBottomLine)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(textFieldContainer)
        view.addSubview(textCountLabel)
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
        
        textCountLabel.anchor(
            top: textFieldContainer.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 8,
            paddingRight: 30
        )
        
        nextButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20,
            height: 56
        )
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
        
        // 글자 수 표시
        textField.rx.text.orEmpty
            .map { "\($0.count)/10" }
            .bind(to: textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 10자 제한
        textField.rx.text.orEmpty
            .map { String($0.prefix(10)) }
            .bind(to: textField.rx.text)
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
                self?.nextButton.alpha = isValid ? 1.0 : 0.5
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
}
