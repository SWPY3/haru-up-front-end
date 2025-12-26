//
//  MissionDeleteView.swift
//  HaruUp
//
//  Created by 조영현 on 12/27/25.
//

import UIKit

final class MissionDeleteView: UIView {
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "삭제 후에는 미션 복구가 불가능해요.\n그래도 미션을 삭제하시겠어요?")
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .cta
        button.setTitle("삭제할래요", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = Typography.body3.font
        button.setTitleColor(.neutral500, for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        configureBackgroundView()
        configureContent()
    }
    
    private func configureBackgroundView() {
        addSubview(bottomSheetView)
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomSheetView.topAnchor.constraint(equalTo: topAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSheetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureContent() {
        bottomSheetView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, deleteButton, cancelButton].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 40),
            contentStackView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 30),
            contentStackView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -30),
            contentStackView.bottomAnchor.constraint(equalTo: bottomSheetView.safeAreaLayoutGuide.bottomAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 56),
            cancelButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        contentStackView.setCustomSpacing(32, after: titleLabel)
        contentStackView.setCustomSpacing(8, after: deleteButton)
    }
}
