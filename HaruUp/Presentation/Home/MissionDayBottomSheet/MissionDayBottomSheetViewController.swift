//
//  MissionDayBottomSheetViewController.swift
//  HaruUp
//
//  Created by 조영현 on 1/2/26.
//

import UIKit
import RxSwift
import RxCocoa

final class MissionDayBottomSheetViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private var bottomSheetViewBottomConstraint: NSLayoutConstraint?
    private let bottomSheetHeight: CGFloat = 506

    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .bottomSheetBackground
        
        return view
    }()
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconChallengeFire
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "연속 미션 달성")
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.setStyledText(Typography.title2, fullText: "3 일차", highlightedText: "3", highlightedColor: .primaryBlue700, defaultColor: .black, highlightedFont: Typography.head2.font)
        
        label.textAlignment = .center
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "시작이 반이에요. 화이팅!")
        label.textColor = .neutral700
        label.textAlignment = .center
        
        return label
    }()
    
    private let dayIconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        
        return stackView
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .cta
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        
        return button
    }()
    
    private var dayViews: [DayItemView] = []
    var countDay: Int = 0
    var weeklyData: [DailyMissionData] = []
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmedViewTap))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }
    
    private func setupView() {
        configureBackgroundView()
        configureImageView()
        configureLabel()
        configureButton()
        configureDayStackView()
    }
    
    private func configureBackgroundView(){
        view.backgroundColor = .clear
        
        [dimmedView, bottomSheetView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.heightAnchor.constraint(equalToConstant: bottomSheetHeight)
        ])
        
        bottomSheetViewBottomConstraint = bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomSheetHeight)
        bottomSheetViewBottomConstraint?.isActive = true
    }
    
    private func configureImageView() {
        bottomSheetView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 62),
            iconImageView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor)
        ])
    }
    
    private func configureLabel() {
        bottomSheetView.addSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, dayLabel, descriptionLabel].forEach {
            textStackView.addArrangedSubview($0)
        }
        
        dayLabel.setStyledText(Typography.title2, fullText: "\(countDay) 일차", highlightedText: "\(countDay)", highlightedColor: .primaryBlue700, defaultColor: .black, highlightedFont: Typography.head2.font)
        
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            textStackView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor)
        ])
    }
    
    private func configureDayStackView() {
        bottomSheetView.addSubview(dayIconStackView)
        dayIconStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for data in weeklyData {
            let view = DayItemView()
            view.configure(data: data)
            dayIconStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            dayIconStackView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 28),
            dayIconStackView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 33),
            dayIconStackView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -33),
            dayIconStackView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -40)
        ])
    }
    
    private func configureButton() {
        bottomSheetView.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -45),
            confirmButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: Actions
    private func setAction() {
        dimmedView.addGestureRecognizer(tapGesture)
        confirmButton.addTarget(self, action: #selector(handleCompleteButtonTap), for: .touchUpInside)
    }
    
    private func showBottomSheet() {
        UIView.animate(withDuration: 0.25) {
            self.dimmedView.alpha = 1 // 설정한 색상이 보이게 됨
        }
        
        self.bottomSheetViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleDimmedViewTap() {
        hideBottomSheet()
    }
    
    @objc private func handleCompleteButtonTap() {
        hideBottomSheet()
    }
    
    private func hideBottomSheet(completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: 0.25) {
            self.dimmedView.alpha = 0
        }
        
        self.bottomSheetViewBottomConstraint?.constant = bottomSheetHeight
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}
