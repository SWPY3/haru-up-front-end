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
    private var animationTopConstraint: NSLayoutConstraint?
    private var shadowBottomConstraint: NSLayoutConstraint?
    
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
        let topConstraint = characterAnimationView.topAnchor.constraint(equalTo: speechBubbleView.bottomAnchor, constant: 20)
        topConstraint.isActive = true
        animationTopConstraint = topConstraint
        characterAnimationView.anchor(width: 260, height: 260)
        
        characterShadowImageView.centerX(inView: characterAnimationView)
        let shadowConstraint = characterShadowImageView.bottomAnchor.constraint(equalTo: characterAnimationView.bottomAnchor, constant: -30)
        shadowConstraint.isActive = true
        shadowBottomConstraint = shadowConstraint
        
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

        // naru는 정사각형 비율이라 haru와 동일한 중심 위치·높이로 맞춤
        // haru 중심 Y = top(20) + height(260)/2 = 150
        // naru top = 150 - height(174)/2 = 63
        let animationSize: CGFloat = output.characterId == 1 ? 260 : 174
        let animationTopPadding: CGFloat = output.characterId == 1 ? 20 : 63
        characterAnimationView.constraints.filter {
            $0.firstAttribute == .width || $0.firstAttribute == .height
        }.forEach { $0.isActive = false }
        NSLayoutConstraint.activate([
            characterAnimationView.widthAnchor.constraint(equalToConstant: animationSize),
            characterAnimationView.heightAnchor.constraint(equalToConstant: animationSize)
        ])
        animationTopConstraint?.constant = animationTopPadding

        // naru는 정사각형으로 여백 없이 꽉 채워지므로 shadow를 발 위치에 맞게 조정
        // haru: 뷰 하단에서 위로 30pt (scaleAspectFit으로 아래 여백 있음)
        // naru: 뷰 하단에서 위로 10pt (여백 없이 꽉 참)
        let shadowBottomPadding: CGFloat = output.characterId == 1 ? -30 : 15
        shadowBottomConstraint?.constant = shadowBottomPadding
        
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
