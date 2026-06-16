//
//  OnboardingViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/2/25.
//

import UIKit

import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: OnboardingViewModel
    
    var onFinish: (() -> Void)? // Onboarding 완료 후 Home으로 이동 콜백
    
    private let gradientView: GradientBackgroundView = {
        let view = GradientBackgroundView(
            startColor: .onboardingStart,
            endColor: .onboardingEnd)
        
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
        return sv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 3
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .neutral100
        pc.currentPageIndicatorTintColor = .neutral1000
        pc.isUserInteractionEnabled = false
        
        return pc
    }()
    
    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("건너뛰기", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        
        return btn
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("다음", for: .normal)
        btn.backgroundColor = .cta
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupOnboardingPages()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ScrollView의 contentSize 재조정 (회전 대응)
        let pageCount = 3
        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(pageCount),
            height: scrollView.frame.height
        )
        
        // 각 페이지 프레임 재조정
        for (index, subview) in scrollView.subviews.enumerated() {
            subview.frame = CGRect(
                x: view.bounds.width * CGFloat(index),
                y: 0,
                width: view.bounds.width,
                height: scrollView.frame.height
            )
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .clear
        configureBackground()
        
        [scrollView, pageControl, nextButton].forEach {
            view.addSubview($0)
        }
        
        scrollView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: pageControl.topAnchor,
            right: view.rightAnchor,
            paddingTop: 0,
            paddingBottom: 14
        )
        
        pageControl.centerX(inView: view)
        pageControl.anchor(
            bottom: nextButton.topAnchor,
            paddingBottom: 28,
            height: 10
        )
        
        nextButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 10,
            paddingRight: 20,
            height: 56
        )
        
        scrollView.delegate = self
    }
    
    private func configureBackground() {
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupOnboardingPages() {
        let pageViews: [OnboardingPageView] = [
            OnboardingPageView(page: .init(title: "AI가 당신의 성장목표를 분석해\n맞춤 미션을 추천해줘요", highlightTitle: "맞춤 미션", description: "현재 내가 도전하기 좋은 5단계의 미션을 추천해요.", image: .imageOnboarding1)),
            OnboardingPageView(page: .init(title: "월간 미션 차트를 참고해서\n미션을 더 쉽게 고르세요.", highlightTitle: "월간 미션 차트", description: "나와 같은 사람들이 얼마나 선택했는지 참고 하세요.", image: .imageOnboarding2)),
            OnboardingPageView(page: .init(title: "미션을 진행하며\n캐릭터와 함께 성장해요", highlightTitle: "캐릭터와 함께 성장해요", description: "미션을 완료해 획득한 경험치로 캐릭터가 성장해요.", image: .imageOnboarding3))
            
        ]
        
        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(pageViews.count),
            height: scrollView.frame.height
        )
        
        for (index, page) in pageViews.enumerated() {
            page.frame = CGRect(
                x: view.bounds.width * CGFloat(index),
                y: 0,
                width: view.bounds.width,
                height: scrollView.frame.height
            )
            
            scrollView.addSubview(page)
        }
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        // Input 연결
        nextButton.rx.tap
            .do(onNext: { [weak self] in
                print("👉 next button tapped")
                let page = self?.viewModel.currentPage.value ?? 0
                let isLast = page == 2
                if isLast {
                    AnalyticsManager.shared.track(event: AppEvent.Onboarding.complete)
                } else {
                    AnalyticsManager.shared.track(event: AppEvent.Onboarding.nextTapped, properties: ["page": page])
                }
            })
               .bind(to: viewModel.nextButtonTapped)
               .disposed(by: disposeBag)

        skipButton.rx.tap
            .do(onNext: { AnalyticsManager.shared.track(event: AppEvent.Onboarding.skipTapped) })
            .bind(to: viewModel.skipButtonTapped)
            .disposed(by: disposeBag)
        
        // Output 연결
        viewModel.currentPage
                .distinctUntilChanged()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] page in
                    guard let self = self else { return }

                    // 페이지 인디케이터
                    self.pageControl.currentPage = page

                    // 실제 화면 이동
                    let offsetX = CGFloat(page) * self.scrollView.bounds.width
                    self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                })
                .disposed(by: disposeBag)

        viewModel.buttonTitle
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                self?.nextButton.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.shouldComplete
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.onFinish?()
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageFromScroll(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageFromScroll(scrollView)
    }

    private func updatePageFromScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard page != viewModel.currentPage.value else { return }
        AnalyticsManager.shared.track(event: AppEvent.Onboarding.swipePage, properties: ["page": page])
        viewModel.currentPage.accept(page)
    }
}
