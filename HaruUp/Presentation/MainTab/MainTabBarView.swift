//
//  MainTabBarView.swift
//  HaruUp
//
//  Created by 조영현 on 12/16/25.
//

import UIKit

final class MainTabBarView: UIView {

    var onSelect: ((MainTab) -> Void)?

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
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.neutral50.cgColor
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 왼쪽 위, 오른쪽 위
        view.layer.masksToBounds = true
        
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        return stackView
    }()

    private var icons: [UIImageView] = []
    private var labels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupItems()
        setSelected(.home)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(
            roundedRect: shadowContainerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 24, height: 24)
        )
        shadowContainerView.layer.shadowPath = path.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        configureBackgroundView()
        configureStackView()
        
        let path = UIBezierPath(
            roundedRect: shadowContainerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 24, height: 24)
        )
        shadowContainerView.layer.shadowPath = path.cgPath
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
    
    private func configureStackView() {
        backgroundView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func setupItems() {
        MainTab.allCases.forEach { tab in
            let item = makeItem(tab: tab)
            stackView.addArrangedSubview(item)
        }
    }

    // TODO: Font style 및 Color 적용해서 사용 필요
    private func makeItem(tab: MainTab) -> UIView {
        let container = UIView()

        let icon = UIImageView(image: tab.icon)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .gray

        let label = UILabel()
        label.text = tab.title
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray

        let vStack = UIStackView(arrangedSubviews: [icon, label])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 6

        container.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        let button = UIButton(type: .system)
        button.tag = tab.rawValue
        button.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        icons.append(icon)
        labels.append(label)

        return container
    }

    @objc private func didTap(_ sender: UIButton) {
        guard let tab = MainTab(rawValue: sender.tag) else { return }
        setSelected(tab)
        onSelect?(tab)
    }

    func setSelected(_ tab: MainTab) {
        for t in MainTab.allCases {
            let i = t.rawValue
            let selected = (t == tab)
            icons[i].image = selected ? t.selectedIcon : t.icon
            icons[i].tintColor = selected ? .systemBlue : .systemGray3
            labels[i].textColor = selected ? .systemBlue : .systemGray3
        }
    }
}
