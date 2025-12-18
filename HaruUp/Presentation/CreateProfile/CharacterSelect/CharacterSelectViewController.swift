//
//  CharacterSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterSelectViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: CreateProfileViewModel
    
    var onNext: ((Int) -> Void)? // 선택된 캐릭터 인덱스를 전달하며 다음 화면으로
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "앞으로 같이 성장해나갈\n성장 메이트를 골라주세요."
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let descriptionBox: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "만나서 반가워요!\n저와 함께 한결음씩 성장하며 가보실까요?"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    private let characterScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.isPagingEnabled = true
        sv.bounces = false
        return sv
    }()
    
    private let characterPageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 2
        pc.currentPage = 0
        pc.pageIndicatorTintColor = UIColor.systemGray4
        pc.currentPageIndicatorTintColor = UIColor.black
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    private let characterNameLabel: UILabel = {
        let label = UILabel()
        label.text = "하루"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("다음", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    // MARK: - Init
    init(viewModel: CreateProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        setupCharacterViews()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenWidth = view.bounds.width
//        let padding: CGFloat = 30
        let characterWidth: CGFloat = 200
        let characterHeight: CGFloat = 200
        
        characterScrollView.contentSize = CGSize(
            width: screenWidth * 2,  // 2페이지
            height: characterScrollView.frame.height
        )
        let centeredX = (screenWidth - characterWidth) / 2
        let centeredY = (characterScrollView.bounds.height - characterHeight) / 2
        
        
        // 캐릭터 뷰들 재배치
        for (index, subview) in characterScrollView.subviews.enumerated() {
            let xPosition = CGFloat(index) * screenWidth + centeredX
            
            subview.frame = CGRect(
                x: xPosition,
                y: centeredY,
                width: characterWidth,
                height: characterHeight
            )
        }
        
    }
    
    // MARK: - Helpers
    private func setupUI() {
        descriptionBox.addSubview(descriptionLabel)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionBox)
        view.addSubview(characterScrollView)
        view.addSubview(characterPageControl)
        view.addSubview(characterNameLabel)
        view.addSubview(nextButton)
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 60,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        descriptionBox.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        descriptionLabel.anchor(
            top: descriptionBox.topAnchor,
            left: descriptionBox.leftAnchor,
            bottom: descriptionBox.bottomAnchor,
            right: descriptionBox.rightAnchor,
            paddingTop: 20,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20
        )
        
        characterScrollView.anchor(
            top: descriptionBox.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 40,
            height: 300
        )
        
        characterPageControl.anchor(
            top: characterScrollView.bottomAnchor,
            paddingTop: 5,
            height: 20
        )
        characterPageControl.centerX(inView: view)
        
        characterNameLabel.anchor(
            top: characterPageControl.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 12
        )
        
        nextButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20,
            height: 56
        )
        
        characterScrollView.delegate = self
    }
    
    private func setupCharacterViews() {
        let characters = ["fox1.png", "fox2.png"]
        
        for (index, imageName) in characters.enumerated() {
            let characterView = createCharacterView(
                imageName: imageName,
                index: index,
                isSelected: index == 0
            )
            characterView.tag = 1000 + index
            
            let tap = UITapGestureRecognizer()
            characterView.addGestureRecognizer(tap)
            tap.rx.event
                .map { _ in index }
                .bind(to: viewModel.characterSelected)
                .disposed(by: disposeBag)
            
            
            characterScrollView.addSubview(characterView)
        }
    }
    
    private func createCharacterView(imageName: String, index: Int, isSelected: Bool) -> UIView {
        let container = UIView()
        container.isUserInteractionEnabled = true
        container.backgroundColor = isSelected ? UIColor(white: 0.88, alpha: 1) : UIColor(white: 0.96, alpha: 1)
        container.layer.cornerRadius = 12
        
        let imageContainer = UIView()
        imageContainer.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
        
        imageContainer.addSubview(imageView)
        container.addSubview(imageContainer)
        

        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageContainer.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.8),  // 화면 너비의 60%
            imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor)  // 정사각형
        ])
        
        // imageView를 imageContainer 안에 꽉 채우기
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leftAnchor.constraint(equalTo: imageContainer.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: imageContainer.rightAnchor)
        ])
        
        
        return container
    }
    
    // MARK: - Update Selection
    private func updateCharacterSelection(selectedIndex: Int) {
        for index in 0..<2 {
            if let characterView = characterScrollView.viewWithTag(1000 + index) {
                let isSelected = index == selectedIndex
                
                UIView.animate(withDuration: 0.3) {
                    // 선택됨: 좀 더 어두운 회색, 선택 안 됨: 연한 회색
                    characterView.backgroundColor = isSelected
                    ? UIColor(white: 0.88, alpha: 1)  // 어두운 회색
                    : UIColor(white: 0.96, alpha: 1)  // 연한 회색
                }
            }
        }
    }
    
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        // Input: 다음 버튼
        nextButton.rx.tap
            .bind(to: viewModel.nextButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.characterSelected
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedIndex in
                self?.updateCharacterSelection(selectedIndex: selectedIndex)
                self?.characterPageControl.currentPage = selectedIndex
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화 (캐릭터 선택되어야 함)
        viewModel.characterSelected
            .map { _ in true }
            .asDriver(onErrorJustReturn: false)
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Output: 닉네임 화면으로 이동
        viewModel.shouldMoveToNickname
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedCharacter in
                print("🎯 선택된 캐릭터: \(selectedCharacter)")
                self?.onNext?(selectedCharacter)
            })
            .disposed(by: disposeBag)
        
        // 캐릭터 선택 변경 시 PageControl 업데이트
        viewModel.characterSelected
            .bind(to: characterPageControl.rx.currentPage)
            .disposed(by: disposeBag)
    }
}

extension CharacterSelectViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.bounds.width))
        
        if page >= 0 && page < 2 {
            viewModel.characterSelected.accept(page)
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.bounds.width))
        
        if page >= 0 && page < 2 {
            viewModel.characterSelected.accept(page)
        }
    }
}
