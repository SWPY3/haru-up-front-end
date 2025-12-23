//
//  CustomAlertViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/23/25.
//

import UIKit

class CustomAlertViewController: UIViewController {
    
    var onConfirm: (() -> Void)?
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "지금은 입력할 수 없어요")
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        let fullText = "목표를 연속으로 3회 잘못 입력했어요.\n30분 후에 다시 입력할 수 있어요."
        let highlightText = "30분 후"
        
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: Typography.body1.font,
                .foregroundColor: UIColor.neutral900
            ]
        )
        let range = (fullText as NSString).range(of: highlightText)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.primaryBlue700,
            range: range
        )
        
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "confirm_btn"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(backgroundView)
        view.addSubview(alertContainerView)
        
        alertContainerView.addSubview(titleLabel)
        alertContainerView.addSubview(messageLabel)
        alertContainerView.addSubview(confirmButton)
        
        
        backgroundView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        
        alertContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alertContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        alertContainerView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        titleLabel.anchor(
            top: alertContainerView.topAnchor,
            left: alertContainerView.leftAnchor,
            right: alertContainerView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        messageLabel.anchor(
            top: titleLabel.bottomAnchor,
            left: alertContainerView.leftAnchor,
            right: alertContainerView.rightAnchor,
            paddingTop: 12,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        confirmButton.anchor(
            top: messageLabel.bottomAnchor,
            left: alertContainerView.leftAnchor,
            bottom: alertContainerView.bottomAnchor,
            right: alertContainerView.rightAnchor,
            paddingTop: 24,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20,
            height: 48
        )
    }
    
    // MARK: - Actions
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        
        backgroundView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func confirmButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }
    
    @objc private func backgroundTapped() {
        // 배경 탭 시에는 아무 동작하지 않음 (또는 dismiss 가능)
    }
}
