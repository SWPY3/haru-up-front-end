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
    
    
    private let disposeBag = DisposeBag()
    
    // 완료 콜백
    var onFinish: ((String) -> Void)?
    
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "원하는 외국어를 입력해주세요."
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "스페인어"
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private let maxHeight: CGFloat = 300
    private var containerViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        // 배경 탭하면 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        
        // 키보드 자동 올리기
        textField.becomeFirstResponder()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        animatePresentation()
//    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        textFieldContainer.addSubview(textField)
        
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textFieldContainer)
        containerView.addSubview(textCountLabel)
        containerView.addSubview(nextButton)
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: maxHeight)
        containerViewHeightConstraint?.isActive = true
        
        containerView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
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
            paddingLeft: 16,
            paddingRight: 16
        )
        
        textCountLabel.anchor(
            top: textFieldContainer.bottomAnchor,
            right: containerView.rightAnchor,
            paddingTop: 8,
            paddingRight: 24
        )
        
        // Confirm Button
        nextButton.anchor(
            left: containerView.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: containerView.rightAnchor,
            paddingLeft: 24,
            paddingBottom: 20,
            paddingRight: 24,
            height: 56
        )
    }
    
    private func setupBindings() {
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
        
        // 버튼 활성화 (1~10자)
        textField.rx.text.orEmpty
            .map { text in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                return trimmed.count >= 1 && trimmed.count <= 10
            }
            .subscribe(onNext: { [weak self] isValid in
                self?.nextButton.isEnabled = isValid
                self?.nextButton.alpha = isValid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        // 확인 버튼 탭
        nextButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    self?.dismiss(animated: true) {
                        self?.onFinish?(trimmed)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
//    private func animatePresentation() {
//        containerView.transform = CGAffineTransform(translationX: 0, y: maxHeight)
//        
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
//            self.containerView.transform = .identity
//        }
//    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
}
