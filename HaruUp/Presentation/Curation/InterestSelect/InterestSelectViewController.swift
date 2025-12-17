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
    
    private let interestSelectedSubject = PublishSubject<String>()
    private var interestButtons: [InterestButton] = []
    private var interests: [Interest] = []
    
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 5.0 / 7.0
        progressBar.tintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심사는 무엇인가요?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "적절한 목표를 추천하기 위해 필요해요.\n가장 우선순위가 높은 관심사를 1개 골라주세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5
        return button
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
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(stackView)
        view.addSubview(titleLabelStackView)
        view.addSubview(interestButtonsStackView)
        view.addSubview(nextButton)
        
        stackView.addArrangedSubview(progressBar)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        stackView.addArrangedSubview(titleLabelStackView)
        
        backButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            paddingTop: 5,
            paddingLeft: 15,
            width: 47,
            height: 47
        )
        
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        titleLabelStackView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        interestButtonsStackView.anchor(
            top: stackView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 56,
            paddingLeft: 30,
            paddingRight: 30
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
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let input = InterestSelectViewModel.Input(
            interestSelected: interestSelectedSubject.asObservable(), nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
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
                    let isSelected = self.interests[index].title == selectedInterest
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedInterest
            .map { $0 != nil }
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
                self?.nextButton.alpha = isEnabled ? 1.0 : 0.5
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
                .map { interest.title }
                .bind(to: interestSelectedSubject)
                .disposed(by: disposeBag)
            
            interestButtons.append(button)
            interestButtonsStackView.addArrangedSubview(button)
        }
    }
}
