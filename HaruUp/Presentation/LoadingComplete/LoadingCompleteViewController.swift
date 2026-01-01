//
//  LoadingCompleteViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/24/25.
//

import UIKit
import Lottie

class LoadingCompleteViewController: UIViewController {

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background_gradation.png")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "맞춤 미션이 준비됐어요!\n확인하러 가볼까요?")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "success")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("좋아요!", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.backgroundColor = .cta
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var onFinish: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationView.play()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(animationView)
        view.addSubview(confirmButton)
        
        backgroundImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 110,
            paddingLeft: 20,
            paddingRight: 20
            
        )
        
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.anchor(
            top: titleLabel.bottomAnchor,
            paddingTop: 135,
            width: 150,
            height: 150
        )
        
        confirmButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 10,
            paddingRight: 20,
            height: 56
        )
    }
    
    private func setAction() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    @objc private func confirmButtonTapped() {
        onFinish?()
    }
}
