//
//  CharacterSelectCompleteViewController.swift
//  HaruUp
//
//  Created by 하다현 on 4/15/26.
//


import UIKit
import RxSwift
import RxCocoa
import Lottie

class CharacterSelectCompleteViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CharacterSelectCompleteViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background_gradation.png")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let speechBubbleView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let characterAnimationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        return view
    }()
    
    private let characterShadowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "character_shadow2.png")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .cta
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = Typography.subtitle2.font
        return btn
    }()
    
    
    // MARK: - Init
    init(viewModel: CharacterSelectCompleteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        characterAnimationView.play()
    }
    
    private func setupUI() {
        [backgroundImageView, speechBubbleView, characterAnimationView, characterShadowImageView, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        backgroundImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        speechBubbleView.centerX(inView: view)
        speechBubbleView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 180, width: 310, height: 114)
        
        
        characterAnimationView.centerX(inView: view)
        characterAnimationView.anchor(top: speechBubbleView.bottomAnchor, paddingTop: 20, width: 260, height: 260)
        
        characterShadowImageView.centerX(inView: characterAnimationView)
        characterShadowImageView.anchor(
            bottom: characterAnimationView.bottomAnchor,
            paddingBottom: 30
            
        )
        
        nextButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingBottom: 10, paddingRight: 20, height: 56)
    }
    
    private func bindViewModel() {
        let input = CharacterSelectCompleteViewModel.Input(
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        let characterName = output.characterId == 1 ? "haru" : "naru"
        
        // 캐릭터 애니메이션 로드
        characterAnimationView.animation = LottieAnimation.named("\(characterName)_animation")
        characterAnimationView.play()
        
        output.currentStep
            .drive(onNext: { [weak self] step in
                guard let self = self else { return }
                
                switch step {
                case .welcome:
                    // 캐릭터별 첫 번째 말풍선 이미지 (텍스트 포함)
                    self.speechBubbleView.image = UIImage(named: "text_box_welcome_character_\(characterName).png")
                    self.nextButton.setTitle("다음", for: .normal)
                    
                case .guide:
                    // 캐릭터별 두 번째 말풍선 이미지 (텍스트 포함)
                    self.speechBubbleView.image = UIImage(named: "text_box_guide_character.png")
                    self.nextButton.setTitle("시작하기", for: .normal)
                }
                
                UIView.transition(with: self.speechBubbleView, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
            })
            .disposed(by: disposeBag)
    }
}
