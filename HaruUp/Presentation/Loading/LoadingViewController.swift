//
//  LoadingViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/23/25.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {
    
    let curationData: CurationData
    let viewModel: LoadingViewModel
    
    let coordinator: LoadingCoordinator
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background_gradation.png")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let fullText = ""
        let highlightText = ""
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loadingCircle")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "입력하신 기본 정보를 분석하고 있어요.")
        label.textColor = .neutral700
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Init
    init(curationData: CurationData, viewModel: LoadingViewModel, coordinator: LoadingCoordinator) {
        self.curationData = curationData
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
        startLoadingAnimation()
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(animationView)
        view.addSubview(descriptionLabel)
        view.addSubview(userInfoStackView)
        
        backgroundImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        
        let fullText = "\(curationData.nickname ?? "")님을 위한\n맞춤 미션을 만드는 중이에요!"
        let highlightText = "맞춤 미션"
        
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: Typography.title2.font,
                .foregroundColor: UIColor.black
            ]
        )
        let range = (fullText as NSString).range(of: highlightText)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.primaryBlue700,
            range: range
        )
        
        titleLabel.attributedText = attributedText
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 90,
            paddingLeft: 20,
            paddingRight: 20
            
        )
        
        
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 40,
            paddingRight: 40,
            height: 100
        )
        
        descriptionLabel.anchor(
            top: animationView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 55,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        userInfoStackView.anchor(
            top: descriptionLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 26,
            paddingLeft: 20,
            paddingRight: 20
        )
    }
    
    // MARK: - Animation
    private func startLoadingAnimation() {
        // 1단계: 기본 정보 박스들
        let phase1Boxes = [
            createInfoBox(title: "성별", content: "\(curationData.gender ?? "")"),
            createInfoBox(title: "나이", content: "\(calculateAge())살"),
            createInfoBox(title: "직업", content: curationData.jobDetail?.jobDetailName ?? curationData.job?.jobName ?? "")
        ]
        // 2단계: 관심사와 목표 박스들
        let phase2Boxes = [
            createInfoBox(title: "관심사", content: curationData.interest?.name ?? ""),
            createInfoBox(title: "세부 관심사", content: curationData.interestDetail?.name ?? ""),
            createInfoBox(title: "목표", content: curationData.goal?.name ?? "")
        ]
        
        // 1단계 박스 추가
        phase1Boxes.forEach { box in
            userInfoStackView.addArrangedSubview(box)
            box.anchor(
                left: userInfoStackView.leftAnchor,
                right: userInfoStackView.rightAnchor,
                height: 50
            )
        }
        
        // 1단계 애니메이션 (0.5초 간격으로 하나씩)
        animateBoxes(phase1Boxes, startDelay: 0.4, interval: 0.7) { [weak self] in
            guard let self = self else { return }
            
            // 1단계 완료 후 1초 대기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // descriptionLabel 변경
                self.updateDescriptionLabel(text: "입력하신 관심사와 목표를 분석하고 있어요")
                
                // 1단계 박스 제거
                phase1Boxes.forEach { box in
                    UIView.animate(withDuration: 0.4, animations: {
                        box.alpha = 0
                        box.transform = CGAffineTransform(translationX: 0, y: -20)
                    }) { _ in
                        box.removeFromSuperview()
                    }
                }
                
                // 2단계 박스 추가
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    phase2Boxes.forEach { box in
                        self.userInfoStackView.addArrangedSubview(box)
                        box.anchor(
                            left: self.userInfoStackView.leftAnchor,
                            right: self.userInfoStackView.rightAnchor,
                            height: 56
                        )
                    }
                    
                    // 2단계 애니메이션
                    self.animateBoxes(phase2Boxes, startDelay: 0.4, interval: 0.7) {
                        // 모든 애니메이션 완료 후 1초 대기 후 다음 화면으로
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.coordinator.onFinsh?()
                        }
                    }
                }
            }
        }
    }
    
    private func animateBoxes(_ boxes: [UIView], startDelay: TimeInterval, interval: TimeInterval, completion: (() -> Void)?) {
        for (index, box) in boxes.enumerated() {
            let delay = startDelay + (interval * Double(index))
            
            UIView.animate(
                withDuration: 0.6,
                delay: delay,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut,
                animations: {
                    box.alpha = 1
                    box.transform = .identity
                },
                completion: { _ in
                    if index == boxes.count - 1 {
                        completion?()
                    }
                }
            )
        }
    }
    
    
    private func updateDescriptionLabel(text: String) {
        UIView.transition(
            with: descriptionLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.descriptionLabel.text = text
            }
        )
    }
    
    // MARK: - Helper Methods
    private func createInfoBox(title: String, content: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(named: "small_check")
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.setStyle(Typography.body1, text: title)
        titleLabel.textColor = .neutral1000
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.setStyle(Typography.body1, text: content)
        contentLabel.textColor = .primaryBlue700
        contentLabel.textAlignment = .right
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12)
        ])
        
        return containerView
    }
    
    private func calculateAge() -> Int {
            guard let birthDateString = curationData.birthDate else { return 0 }
            
            // "20011029" 형식의 문자열을 파싱
            guard birthDateString.count == 8 else { return 0 }
            
            let yearString = String(birthDateString.prefix(4))
            let monthString = String(birthDateString.dropFirst(4).prefix(2))
            let dayString = String(birthDateString.suffix(2))
            
            guard let year = Int(yearString),
                  let month = Int(monthString),
                  let day = Int(dayString) else {
                return 0
            }
            
            // 생년월일 Date 객체 생성
            var birthDateComponents = DateComponents()
            birthDateComponents.year = year
            birthDateComponents.month = month
            birthDateComponents.day = day
            
            guard let birthDate = Calendar.current.date(from: birthDateComponents) else {
                return 0
            }
            
            // 현재 날짜와 비교하여 나이 계산
            let now = Date()
            let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: now)
            
            return ageComponents.year ?? 0
        }
    
    private func navigateToMissionComplete() {
            // 미션 추천 완료 화면으로 전환하는 로직
            // 예: coordinator를 통해 화면 전환
            // viewModel.navigateToMissionComplete()
            print("미션 추천 완료 화면으로 이동")
        }
}
