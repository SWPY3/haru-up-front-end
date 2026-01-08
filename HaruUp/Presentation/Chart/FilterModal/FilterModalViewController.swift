//
//  FilterModalViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/8/26.
//

import UIKit

class FilterModalViewController: UIViewController {
    
    // MARK: - UI Components
    // 1. 고정 헤더
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "필터"
        label.font = Typography.subtitle1.font
        label.textColor = .black
        return label
    }()
    
    private let titleLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        return view
    }()
    
    // 2. 스크롤 영역 (Body)
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    // 스크롤 뷰 안의 내용을 담을 스택뷰
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 28
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    // 3. 고정 푸터 (Bottom Buttons)
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.neutral100.cgColor
        button.backgroundColor = .white
        return button
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton()
        button.setTitle("결과 보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.layer.cornerRadius = 12
        button.backgroundColor = .cta
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        //        view.layer.cornerRadius = 20
        //        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단만 둥글게
        //        view.clipsToBounds = true
        
        [closeButton, applyButton].forEach { buttonStackView.addArrangedSubview($0) }
        
        [titleLabel, titleLineView, scrollView, buttonStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 1. 헤더 (고정)
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 34.5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            titleLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLineView.heightAnchor.constraint(equalToConstant: 1),
            
            // 2. 스크롤 뷰 (중간 영역)
            scrollView.topAnchor.constraint(equalTo: titleLineView.bottomAnchor, constant: 5),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -10),
            
            // 스크롤 뷰 내부 컨텐츠
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40), // 좌우 패딩 고려
            
            // 3. 푸터 버튼 (하단 고정)
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            
            // 닫기 버튼 비율 (1 : 2 정도) 혹은 고정 너비
            closeButton.widthAnchor.constraint(equalTo: applyButton.widthAnchor, multiplier: 0.35)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    @objc private func applyFilter() {
        // 필터 적용 로직 구현
        print("필터 적용")
        dismiss(animated: true)
    }
    
    // MARK: - Data Rendering
    private func setupData() {
        addSection(title: "성별", tags: ["남성", "여성"])
        addSection(title: "연령대", tags: ["전체", "19세 이하", "20 - 24세", "25 - 29세", "30 - 34세", "35 - 39세", "40세 이상"])
        addSection(title: "직업", tags: ["직장인", "자영업", "학생", "취준생"])
        addSection(title: "세부 직무", tags: ["디자이너", "기획자", "개발자", "사무직", "서비스직", "교육 종사자", "의료직", "공공·복지", "예체능"])
        addSection(title: "관심사", tags: ["외국어 공부", "자격증 공부", "재테크/투자", "체력관리 및 운동", "직무 관련 역량 개발"])
    }
    
    private func addSection(title: String, tags: [String]) {
        let sectionView = UIView()
        
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.font = Typography.subtitle2.font
        headerLabel.textColor = .neutral1000
        
        let tagLayoutView = TagLayoutView()
        tagLayoutView.tags = tags
        
        [headerLabel, tagLayoutView].forEach {
            sectionView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            
            tagLayoutView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            tagLayoutView.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            tagLayoutView.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            tagLayoutView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor)
        ])
        
        contentStackView.addArrangedSubview(sectionView)
    }
    // MARK: - Custom Tag Layout Helper
    // 태그들이 자동으로 줄바꿈되도록 하는 커스텀 뷰
    class TagLayoutView: UIView {
        
        var tags: [String] = [] {
            didSet { setupTags() }
        }
        
        private func setupTags() {
            subviews.forEach { $0.removeFromSuperview() }
            
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            let spacingX: CGFloat = 8
            let spacingY: CGFloat = 8
            let containerWidth = UIScreen.main.bounds.width - 40 // 좌우 패딩 제외 너비 예측
            
            var lastView: UIView?
            
            for text in tags {
                let button = createTagButton(text: text)
                addSubview(button)
                
                // 사이즈 계산을 위해 레이아웃 강제 업데이트
                button.layoutIfNeeded()
                let buttonSize = button.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                
                // 다음 줄로 넘어가야 하는지 확인
                if currentX + buttonSize.width > containerWidth {
                    currentX = 0
                    currentY += buttonSize.height + spacingY
                }
                
                button.frame = CGRect(x: currentX, y: currentY, width: buttonSize.width, height: buttonSize.height)
                currentX += buttonSize.width + spacingX
                lastView = button
            }
            
            // 전체 높이 제약조건 설정
            if let lastView = lastView {
                self.heightAnchor.constraint(equalToConstant: lastView.frame.maxY).isActive = true
            }
        }
    }
