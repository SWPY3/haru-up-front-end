//
//  FilterModalViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/8/26.
//

import UIKit


// 1. 데이터를 전달할 프로토콜 정의
protocol FilterModalDelegate: AnyObject {
    func didApplyFilter(selectedTags: [String])
}

class FilterModalViewController: UIViewController {
    
    weak var delegate: FilterModalDelegate?
    
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
        stack.spacing = 26
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
        setupData()
        setupActions()
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
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            titleLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLineView.heightAnchor.constraint(equalToConstant: 1),
            
            // 2. 스크롤 뷰 (중간 영역)
            scrollView.topAnchor.constraint(equalTo: titleLineView.bottomAnchor, constant: 28),
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
        
        titleLabel.isUserInteractionEnabled = true // 라벨이 터치를 먹을 수 있게 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    @objc private func applyFilter() {
        // 필터 적용 로직 구현
        print("필터 적용")
        var selectedTags: [String] = []
        
        // contentStackView 내의 모든 TagLayoutView를 순회하며 선택된 버튼 찾기
        for case let sectionView as UIView in contentStackView.arrangedSubviews {
            for case let tagLayoutView as TagLayoutView in sectionView.subviews {
                selectedTags.append(contentsOf: tagLayoutView.getSelectedTags())
            }
        }
        
        delegate?.didApplyFilter(selectedTags: selectedTags)
        dismiss(animated: true)
    }
    
    @objc private func titleLabelTapped() {
        guard let sheet = self.sheetPresentationController else { return }
        
        // 애니메이션과 함께 높이 변경
        sheet.animateChanges {
            // 현재 상태가 .large가 아니면 .large로 변경 (Medium -> Large)
            // 만약 토글(Medium <-> Large)을 원하시면 if 문을 수정하면 됩니다.
            if sheet.selectedDetentIdentifier != .large {
                sheet.selectedDetentIdentifier = .large
            } else {
                // (선택사항) 이미 Large 상태일 때 누르면 다시 Medium으로 줄이고 싶다면:
                sheet.selectedDetentIdentifier = .medium
            }
        }
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
}
// MARK: - Custom Tag Layout Helper
// 태그들이 자동으로 줄바꿈되도록 하는 커스텀 뷰
class TagLayoutView: UIView {
    
    var tags: [String] = [] {
        didSet { setupTags() }
    }
    
    func getSelectedTags() -> [String] {
        var selected: [String] = []
        for subview in subviews {
            if let button = subview as? UIButton, button.isSelected {
                if let attributedTitle = button.configuration?.attributedTitle {
                    let title = String(attributedTitle.characters)
                    selected.append(title)
                }
                
            }
        }
        return selected
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
    
    private func createTagButton(text: String) -> UIButton {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        var container = AttributeContainer()
        container.font = Typography.body4.font
        config.attributedTitle = AttributedString(text, attributes: container)
        
        config.baseForegroundColor = .neutral800
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        config.background.cornerRadius = 10
        config.cornerStyle = .fixed
        
        config.background.strokeColor = .neutral100
        config.background.strokeWidth = 1
        config.background.backgroundColor = .white
        
        button.configuration = config
        // 버튼 클릭 시 색상 변경 액션 추가
        button.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func tagTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // 1. 현재 설정 가져오기
        guard var config = sender.configuration else { return }
        
        // 2. 폰트와 색상을 담을 컨테이너 생성
        var container = AttributeContainer()
        container.font = Typography.body4.font
        
        if sender.isSelected {
            container.foregroundColor = .primaryBlue700
            config.background.backgroundColor = .primaryBlue50
            config.background.strokeColor = .primaryBlue700
        } else {
            container.foregroundColor = .neutral800
            config.background.backgroundColor = .white
            config.background.strokeColor = .neutral100
        }
        // 3. 기존 텍스트 내용을 가져와서 새로운 속성(색상) 적용
        // (attributedTitle.string을 통해 순수 텍스트만 가져옵니다)
        if let attributedTitle = config.attributedTitle {
            let currentText = String(attributedTitle.characters)
            config.attributedTitle = AttributedString(currentText, attributes: container)
        }
        
        // 4. 버튼에 설정 반영
        sender.configuration = config
    }
    
}


