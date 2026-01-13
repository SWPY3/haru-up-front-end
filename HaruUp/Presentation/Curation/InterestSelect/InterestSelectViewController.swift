//
//  InterestSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

class InterestSelectViewController: UIViewController {
    
    private let viewModel:  InterestSelectViewModel
    private let disposeBag = DisposeBag()
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let interestSelectedSubject = PublishSubject<Interest>()
    private var interestButtons: [InterestButton] = []
    private var interests: [Interest] = []
    
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .primaryBlue700
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron_left.png"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 6.0 / 8.0
        progressBar.tintColor = .primaryBlue700
        progressBar.trackTintColor = .neutral50
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심사는 무엇인가요?"
        label.setStyle(Typography.title2, text: "관심사는 무엇인가요?")
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "적절한 목표를 추천하기 위해 필요해요.\n가장 우선순위가 높은 관심사를 1개 골라주세요.")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .neutral700
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 35
        return sv
    }()
    
    private let titleLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 12
        return sv
    }()
    
    private let interestButtonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 12
        return sv
    }()
    
    private let listBlurView: UIImageView = {
        let blurView = UIImageView()
        blurView.image = .imageListBlur
        blurView.contentMode = .scaleAspectFill
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("다음", for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.backgroundColor = .neutral200
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    init(viewModel: InterestSelectViewModel) {
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
        
        viewDidLoadSubject.onNext(())
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(stackView)

        view.addSubview(interestButtonsStackView)
        view.addSubview(listBlurView)
        view.addSubview(nextButton)
        view.addSubview(activityIndicator)
        
        stackView.addArrangedSubview(progressBar)
        stackView.addArrangedSubview(titleLabelStackView)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        backButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            paddingTop: 10,
            paddingLeft: 20,
            width: 20,
            height: 20
        )
        
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        progressBar.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        titleLabelStackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        interestButtonsStackView.anchor(
            top: stackView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 56,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        listBlurView.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor
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
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let input = InterestSelectViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            interestSelected: interestSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.interestButtonsStackView.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.interestButtonsStackView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        output.interests
            .drive(onNext: { [weak self] interests in
                self?.interests = interests
                self?.createInterestButtons(with: interests)
            })
            .disposed(by: disposeBag)
        
        
        output.selectedInterest
            .drive(onNext: { [weak self] selectedInterest in
                guard let self = self else { return }
                
                self.interestButtons.enumerated().forEach { index, button in
                    let isSelected = self.interests[index].id == selectedInterest?.id
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedInterest
            .map { $0 != nil }
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
                self?.nextButton.backgroundColor = isEnabled ? .cta : .neutral200
            })
            .disposed(by: disposeBag)
    }
    
    private func createInterestButtons(with interests: [Interest]) {
        interestButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        interestButtons.removeAll()
        
        interests.forEach { interest in
            let button = InterestButton()
            button.configure(icon: interest.icon, title: interest.title)  
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            button.rx.tap
                .map { interest }
                .bind(to: interestSelectedSubject)
                .disposed(by: disposeBag)
            
            interestButtons.append(button)
            interestButtonsStackView.addArrangedSubview(button)
        }
    }
}
