//
//  AgreementCell.swift
//  HaruUp
//
//  Created by 하다현 on 1/15/26.
//

import UIKit
import RxSwift
import RxCocoa

final class AgreementCell: UIView {
    // UI Events
    let checkButtonTap = PublishRelay<Void>()
    let arrowButtonTap = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // UI Components
    private let checkButton: UIButton = {
        let button = UIButton()
        // 체크박스 이미지 설정 (sf symbol 예시)
        button.setImage(.iconCheckBoxUnselected, for: .normal)
        button.setImage(.iconCheckBoxSelected, for: .selected)
//        button.tintColor = .gray // 비활성 컬러
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral700
        return label
    }()
    
    // 오른쪽 화살표 버튼
    private let arrowButton: UIButton = {
        let button = UIButton()
        button.setImage(.chevronRightGray, for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    init(title: String, font: UIFont, hasArrow: Bool = true) {
        super.init(frame: .zero)
        setupLayout(hasArrow: hasArrow)
        titleLabel.text = title
        titleLabel.font = font
        bind()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // 외부에서 체크 상태를 변경하기 위한 함수
    func setChecked(_ isChecked: Bool) {
        checkButton.isSelected = isChecked
//        checkButton.tintColor = isChecked ? .systemBlue : .gray // 선택시 색상 변경
    }
    
    private func bind() {
        checkButton.rx.tap
            .bind(to: checkButtonTap)
            .disposed(by: disposeBag)
        
        arrowButton.rx.tap
            .bind(to: arrowButtonTap)
            .disposed(by: disposeBag)
    }
    
    private func setupLayout(hasArrow: Bool) {
        addSubview(checkButton)
        addSubview(titleLabel)
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 20),
            checkButton.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if hasArrow {
            addSubview(arrowButton)
            arrowButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                arrowButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                arrowButton.widthAnchor.constraint(equalToConstant: 24),
                arrowButton.heightAnchor.constraint(equalToConstant: 24),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowButton.leadingAnchor, constant: -8)
            ])
        } else {
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        }
        
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
