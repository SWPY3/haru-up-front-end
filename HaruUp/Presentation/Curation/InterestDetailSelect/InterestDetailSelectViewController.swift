//
//  InterestDetailSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

class InterestDetailSelectViewController: UIViewController {
    private let viewModel: InterestDetailSelectViewModel
    private let disposeBag = DisposeBag()
    
    
    private let interestDetailSelectedSubject = PublishSubject<String>()
    private var interestDetailButtons: [SelectButton] = []
    private var interestDetails: [String] = []
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 6.0 / 7.0
        progressBar.tintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "세부 관심사는 무엇인가요?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심사의 세부 분야를 1개 골라주세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let interestDetailButtonsStackView: UIStackView = {
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
    
    
    
    init(viewModel: InterestDetailSelectViewModel) {
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
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(stackView)
        view.addSubview(interestDetailButtonsStackView)
        view.addSubview(nextButton)
        
        stackView.addArrangedSubview(progressBar)
        stackView.addArrangedSubview(titleLabelStackView)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        
        
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
        
        interestDetailButtonsStackView.anchor(
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
    
    private func bindViewModel() {
        backButton.rx.tap
            .subscribe(onNext: { [ weak self ] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let input = InterestDetailSelectViewModel.Input(
            interestDetailSelected: interestDetailSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        
        output.interestDetails
            .drive(onNext: { [weak self] interestDetails in
                self?.interestDetails = interestDetails
                self?.createInterestDetailButtons(with: interestDetails)
            })
            .disposed(by: disposeBag)
        
        output.selectedInterestDetail
            .drive(onNext: { [weak self] selectedInterestDetail in
                guard let self = self else { return }
                
                self.interestDetailButtons.enumerated().forEach { index, button in
                    let isSelected = self.interestDetails[index] == selectedInterestDetail
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화
        output.selectedInterestDetail
            .map{ $0 != nil }
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
                self?.nextButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
    }
    
    private func createInterestDetailButtons(with interestDetails: [String]) {
        interestDetailButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        interestDetailButtons.removeAll()
        
        interestDetails.forEach { interestDetail in
            let button = SelectButton()
            button.setTitle(interestDetail, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            button.rx.tap
                .map { interestDetail }
                .bind(to: interestDetailSelectedSubject)
                .disposed(by: disposeBag)
            
            interestDetailButtons.append(button)
            interestDetailButtonsStackView.addArrangedSubview(button)
        }
    }
}
