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
    private let viewModel: CharacterSelectViewModel
    private let disposeBag = DisposeBag()
    
    private let currentCharacterIndex = BehaviorRelay<Int>(value: 1)
    
    private let characters: [(name: String, image: String, textImage: String)] = [
        (name: "하루", image: "haru_level1", textImage: "text_box_character_haru"),
        (name: "나루", image: "naru_level1", textImage: "text_box_character_naru")
    ]
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background_gradation.png")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "앞으로 함께 성장할\n메이트를 선택해주세요!")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let characterTextImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "text_character_haru.png")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let characterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "haru_level1.png")
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let characterShadowImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "character_shadow2.png")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let characterNameLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "하루")
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftArrowButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "chevron_left.png"), for: .normal)
        btn.isEnabled = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let rightArrowButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "chevron_right.png"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "next_btn_blue.png"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    
    // MARK: - Init
    init(viewModel: CharacterSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        setupGestures()
        updateCharacterDisplay(at: 1)
    }
    
    
    
    // MARK: - Helpers
    private func setupUI() {
        view.insertSubview(backgroundImageView, at: 0)
    
        view.addSubview(titleLabel)
        view.addSubview(characterTextImageView)
        view.addSubview(characterImageView)
        view.addSubview(characterShadowImageView)
        view.addSubview(characterNameLabel)
        view.addSubview(leftArrowButton)
        view.addSubview(rightArrowButton)
        view.addSubview(nextButton)
        
        backgroundImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 80,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        characterTextImageView.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 80,
            paddingLeft: 40,
            paddingRight: 40,
            height: 100
        )
        
        characterImageView.centerX(inView: view)
        characterImageView.anchor(
            top: characterTextImageView.bottomAnchor,
            width: 180,
            height: 180
        )
        
        characterShadowImageView.centerX(inView: characterImageView)
        characterShadowImageView.anchor(
            bottom: characterNameLabel.topAnchor,
            paddingBottom: 5
            
        )
    
        leftArrowButton.anchor(
            top: characterImageView.topAnchor,
            left: view.leftAnchor,
            paddingTop: 110,
            paddingLeft: 20,
            width: 32,
            height: 32
        )
        
        rightArrowButton.anchor(
            top: characterImageView.topAnchor,
            right: view.rightAnchor,
            paddingTop: 110,
            paddingRight: 20,
            width: 32,
            height: 32
        )
        
        characterNameLabel.anchor(
            top: characterImageView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20
        )

        
        nextButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 5,
            paddingRight: 20,
            height: 56
        )
        
        
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer()
        characterImageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.showNextCharacter()
            })
            .disposed(by: disposeBag)
        
        
        // 화살표 버튼 액션
        leftArrowButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showPreviousCharacter()
            })
            .disposed(by: disposeBag)
        
        rightArrowButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showNextCharacter()
            })
            .disposed(by: disposeBag)
        
        // 현재 인덱스 변경 감지
        currentCharacterIndex
            .subscribe(onNext: { [weak self] index in
                self?.updateCharacterDisplay(at: index)
            })
            .disposed(by: disposeBag)
    }
    
    private func showPreviousCharacter() {
        let currentIndex = currentCharacterIndex.value
        if currentIndex > 1 {
            currentCharacterIndex.accept(currentIndex - 1)
        }
    }
    
    private func showNextCharacter() {
        let currentIndex = currentCharacterIndex.value
        if currentIndex < characters.count  {
            currentCharacterIndex.accept(currentIndex + 1)
        } else {
            currentCharacterIndex.accept(1)
        }
    }
    
    private func updateCharacterDisplay(at index: Int) {
        
        guard index >= 1 && index < characters.count + 1 else {
            print("❌ 잘못된 인덱스: \(index)")
            return
        }
        
        let character = characters[index - 1]
        
        guard let charImage = UIImage(named: character.image) else {
            print("❌ 캐릭터 이미지 로드 실패: \(character.image)")
            return
        }
        
        guard let textImage = UIImage(named: character.textImage) else {
            print("❌ 말풍선 이미지 로드 실패: \(character.textImage)")
            return
        }
        
        // 페이드 애니메이션으로 자연스럽게 전환
        UIView.transition(with: characterImageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve) { [weak self] in
            self?.characterImageView.image = UIImage(named: character.image)
        }
        
        UIView.transition(with: characterTextImageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve) { [weak self] in
            self?.characterTextImageView.image = UIImage(named: character.textImage)
        }
        
        characterNameLabel.text = character.name
        
        // 화살표 버튼 활성화/비활성화
        leftArrowButton.isEnabled = index > 1
        leftArrowButton.alpha = index > 1 ? 1.0 : 0.2
        
        rightArrowButton.isEnabled = index < characters.count
        rightArrowButton.alpha = index < characters.count ? 1.0 : 0.2
        
    }
    
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        let input = CharacterSelectViewModel.Input(
            characterSelected: currentCharacterIndex.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.isValid
            .drive(onNext: { [weak self] isValid in
                self?.nextButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
    }
}

