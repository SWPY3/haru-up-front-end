//
//  ExitConfirmModalViewController.swift
//  HaruUp
//
//  Created by 하다현 on 4/16/26.
//

import UIKit

class ExitConfirmModalViewController: UIViewController {
    // MARK: - Properties
    var onRestartTapped: (() -> Void)?
    var onContinueTapped: (() -> Void)?
    
    // MARK: - UI Components
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let characterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .characterCurationClose
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "처음부터 다시 시작할까요?\n지금까지 작성한 답변은 저장되지 않아요.")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let restartButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("처음부터 다시 시작하기", for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.backgroundColor = .cta
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private let continueButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("계속 진행하기", for: .normal)
        btn.setTitleColor(.neutral500, for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(containerView)
        
        [characterImageView, titleLabel, restartButton, continueButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 430)
        ])
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            characterImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 110),
            characterImageView.heightAnchor.constraint(equalToConstant: 110)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 30),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -30),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            restartButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            restartButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20),
            restartButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20),
            restartButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 16),
            continueButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
        // 배경 터치 시 닫기
        let tap = UITapGestureRecognizer(target: self, action: #selector(continueTapped))
        dimView.addGestureRecognizer(tap)
    }
    
    @objc private func restartTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onRestartTapped?()
        }
    }
    
    @objc private func continueTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onContinueTapped?()
        }
    }
    
}
