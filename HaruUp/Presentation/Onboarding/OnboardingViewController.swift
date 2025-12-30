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
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
        return sv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 2
        pc.currentPage = 0
        pc.pageIndicatorTintColor = UIColor.systemGray4
        pc.currentPageIndicatorTintColor = UIColor.systemGreen
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
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 8
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
        
        view.backgroundColor = .white
        setupUI()
        setupOnboardingPages()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ScrollView의 contentSize 재조정 (회전 대응)
        let pageCount = 2
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
        [skipButton, scrollView, pageControl, nextButton].forEach {
            view.addSubview($0)
        }

        skipButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            right: view.rightAnchor,
            paddingTop: 16,
            paddingRight: 20,
            height: 44
        )
        
        scrollView.anchor(
            top: skipButton.bottomAnchor,
            left: view.leftAnchor,
            bottom: pageControl.topAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
            paddingBottom: 20
        )
        
        pageControl.centerX(inView: view)
        pageControl.anchor(
            bottom: nextButton.topAnchor,
            paddingBottom: 20,
            height: 20
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
        
        scrollView.delegate = self
    }
    
    
    private func setupOnboardingPages() {
        let pages: [(title: String, description: String)] = [
            (
                title: "AI가 당신의 목표를 분석해\n맞춤형 미션을 추천드려요!",
                description: "분석하는 기능?아이콘\nQ/A 주고 받는 아이콘\n\n 핸드폰 화면 안들어감..\n생각중임..."
            ),
            (
                title: "관심사별 미션 차트를 참고해\n미션을 더 쉽게 고르세요.",
                description: "관심사, 직무별\n랭킹표 혹은 다른\n아이콘.\n\n핸드폰 화면 안들어감...\n샘각중임.."
            )
        ]
        
        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(pages.count),
            height: scrollView.frame.height
        )
        
        for (index, page) in pages.enumerated() {
            let pageView = createPageView(title: page.title, description: page.description)
            
            pageView.frame = CGRect(
                x: view.bounds.width * CGFloat(index),
                y: 0,
                width: view.bounds.width,
                height: scrollView.frame.height
            )
            scrollView.addSubview(pageView)
        }
    }
    

    private func createPageView(title: String, description: String)  -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        // 설명 박스
        let descriptionBox = UIView()
        descriptionBox.backgroundColor = UIColor(white: 0.95, alpha: 1)
        descriptionBox.layer.cornerRadius = 12
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        
        descriptionBox.addSubview(descriptionLabel)
        container.addSubview(titleLabel)
        container.addSubview(descriptionBox)
        
        // 타이틀 레이아웃
        titleLabel.anchor(
            top: container.topAnchor,
            left: container.leftAnchor,
            right: container.rightAnchor,
            paddingTop: 60,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        // 설명 박스 레이아웃
        descriptionBox.anchor(
            top: titleLabel.bottomAnchor,
            left: container.leftAnchor,
            right: container.rightAnchor,
            paddingTop: 80,
            paddingLeft: 40,
            paddingRight: 40
        )
        
        // 설명 라벨 레이아웃 (박스 내부)
        descriptionLabel.anchor(
            top: descriptionBox.topAnchor,
            left: descriptionBox.leftAnchor,
            bottom: descriptionBox.bottomAnchor,
            right: descriptionBox.rightAnchor,
            paddingTop: 30,
            paddingLeft: 20,
            paddingBottom: 30,
            paddingRight: 20
        )
        
        return container
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        // Input 연결
        nextButton.rx.tap
            .do(onNext: { print("👉 next button tapped") })
               .bind(to: viewModel.nextButtonTapped)
               .disposed(by: disposeBag)
        
        skipButton.rx.tap
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
        viewModel.currentPage.accept(page)
    }
}
