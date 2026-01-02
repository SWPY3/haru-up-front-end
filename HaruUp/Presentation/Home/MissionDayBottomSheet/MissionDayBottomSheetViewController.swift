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
    
    private let dayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        
        return stackView
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.head1, text: "1")
        label.textColor = .primaryBlue700
        
        return label
    }()
    
    private let dayUnitLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "일차")
        label.textColor = .black
        
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
        button.setTitle("삭제할래요", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        
        return button
    }()
    
    private var dayViews: [DayItemView] = []
    var weeklyData: [DailyMissionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }
    
    private func setupView() {
        configureBackgroundView()
        configureImageView()
        configureLabel()
        configureDayStackView()
        configureButton()
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
        
        [titleLabel, dayStackView, descriptionLabel].forEach {
            textStackView.addArrangedSubview($0)
        }
        
        [dayLabel, dayUnitLabel].forEach {
            dayStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            textStackView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor)
        ])
    }
    
    private func configureDayStackView() {
        bottomSheetView.addSubview(dayStackView)
        dayStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, data) in weeklyData.enumerated() {
            let view = DayItemView()
            view.configure(data: data)
            dayStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            dayStackView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 28),
            dayStackView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 33),
            dayStackView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -33)
        ])
    }
    
    private func configureButton() {
        bottomSheetView.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: dayStackView.bottomAnchor, constant: 40),
            confirmButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -45),
            confirmButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
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
}
