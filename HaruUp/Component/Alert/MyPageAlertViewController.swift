//
//  MyPageAlertViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/31/25.
//

import UIKit

class MyPageAlertViewController: UIViewController {
    enum AlertType {
        case confirmation // 확인/취소 (2버튼)
        case success      // 확인 (1버튼)
    }
    
    private let alertType: AlertType
    var onConfirm: (() -> Void)?
    
    // MARK: - UI Components
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 버튼들을 담을 스택뷰
    private let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    
    private let cancelButton = UIButton()
    private let confirmButton = UIButton()
    
    // 단일 확인 버튼 (성공 알림용)
    private let singleConfirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .primaryBlue700
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    init(title: String,
         message: String,
         type: AlertType = .confirmation,
         confirmTitle: String,
         cancelTitle: String? = nil,
         confirmColor: UIColor = .primaryBlue700,
         cancelColor: UIColor = .neutral700) {
        
        self.alertType = type
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.setStyle(Typography.subtitle1, text: title)
        titleLabel.textColor = .black
        
        messageLabel.setStyle(Typography.body1, text: message)
        messageLabel.textColor = .neutral900
        
        setupButtons(type: type,
                     confirmTitle: confirmTitle,
                     cancelTitle: cancelTitle,
                     confirmColor: confirmColor,
                     cancelColor: cancelColor)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupButtons(type: AlertType, confirmTitle: String, cancelTitle: String?, confirmColor: UIColor, cancelColor: UIColor) {
        if type == .confirmation {
            // 버튼 폰트 및 색상 설정
            cancelButton.setAttributedTitle(createStyledButtonTitle(text: cancelTitle ?? "", style: Typography.body1, color: cancelColor), for: .normal)
            confirmButton.setAttributedTitle(createStyledButtonTitle(text: confirmTitle, style: Typography.body1, color: confirmColor), for: .normal)
        } else {
            // 성공 알림 버튼 (Typography.body3, white)
            singleConfirmButton.setAttributedTitle(createStyledButtonTitle(text: confirmTitle, style: Typography.body3, color: .white), for: .normal)
        }
    }
    
    private func createStyledButtonTitle(text: String, style: FontStyle, color: UIColor) -> NSAttributedString {
        let font = style.font
        return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(dimView)
        dimView.edgeConstraints(to: view)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        
        
        // 버튼 레이아웃 구성
        if alertType == .confirmation {
            containerView.addSubview(buttonStackView)
            buttonStackView.addArrangedSubview(cancelButton)
            buttonStackView.addArrangedSubview(confirmButton)
            
            // 1. 가로 구분선 (메시지와 버튼 사이)
            let horizontalLine = UIView()
            horizontalLine.backgroundColor = .neutral50
            horizontalLine.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(horizontalLine)
            
            // 2. 세로 구분선 (아니요와 예 버튼 사이)
            let verticalLine = UIView()
            verticalLine.backgroundColor = .neutral50
            verticalLine.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(verticalLine)
            
            
            NSLayoutConstraint.activate([
                buttonStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
                buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                buttonStackView.heightAnchor.constraint(equalToConstant: 56),
                
                // 가로선 제약
                horizontalLine.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
                horizontalLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                horizontalLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                horizontalLine.heightAnchor.constraint(equalToConstant: 1),
                
                // 세로선 제약 - 추가된 부분
                verticalLine.centerXAnchor.constraint(equalTo: buttonStackView.centerXAnchor),
                verticalLine.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor),
                verticalLine.widthAnchor.constraint(equalToConstant: 1),
                verticalLine.heightAnchor.constraint(equalTo: buttonStackView.heightAnchor)
            ])
        } else {
            containerView.addSubview(singleConfirmButton)
            NSLayoutConstraint.activate([
                singleConfirmButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
                singleConfirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                singleConfirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                singleConfirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
                singleConfirmButton.heightAnchor.constraint(equalToConstant: 48)
            ])
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        cancelButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        singleConfirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }
    
    @objc private func dismissAlert() { dismiss(animated: true) }
    
    @objc private func confirmAction() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }
}

extension UIView {
    func edgeConstraints(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
