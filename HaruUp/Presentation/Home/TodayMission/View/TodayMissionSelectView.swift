//
//  TodayMissionSelectView.swift
//  HaruUp
//
//  Created by 조영현 on 12/24/25.
//

import UIKit

final class TodayMissionSelectView: UIView {
    
    private let shadowContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.tabbarShadow.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: -10)
        view.layer.shadowRadius = 22 / 2 /// Figma의 Blur를 적용할 때 /2
        
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 왼쪽 위, 오른쪽 위
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let hStackview: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body3, text: "추가 선택 가능한 미션")
        label.textColor = .black
        
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "0개")
        label.textColor = .cta // 0개인 경우 .neutral400
        
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("선택 완료", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .cta
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureBackgroundShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .neutral10
        
        configureBackgroundView()
        configureBackgroundShadow()
        configureLabel()
        configureButton()
    }
    
    private func configureBackgroundView() {
        addSubview(shadowContainerView)
        shadowContainerView.addSubview(backgroundView)

        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shadowContainerView.topAnchor.constraint(equalTo: topAnchor),
            shadowContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowContainerView.bottomAnchor.constraint(equalTo:bottomAnchor),
        
            backgroundView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),
        ])
    }
    
    private func configureBackgroundShadow() {
        let path = UIBezierPath(
            roundedRect: shadowContainerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 24, height: 24)
        )
        
        shadowContainerView.layer.shadowPath = path.cgPath
    }
    
    private func configureLabel() {
        backgroundView.addSubview(hStackview)
        hStackview.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, countLabel].forEach {
            hStackview.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            hStackview.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            hStackview.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20)
        ])
    }
    
    private func configureButton() {
        backgroundView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: hStackview.trailingAnchor, constant: 32),
            button.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 152),
            button.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    func updateSelectionCount(_ count: Int) {
        let allCount: Int = 5
        let selectableCount = allCount - count
        let countText = "\(selectableCount)개"
        
        countLabel.setStyle(Typography.title3, text: countText)
        countLabel.textColor = selectableCount == 0 ? .neutral400 : .cta
    }
}
