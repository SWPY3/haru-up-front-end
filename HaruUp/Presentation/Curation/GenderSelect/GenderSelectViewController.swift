//
//  GenderSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa


class GenderSelectViewController: UIViewController {
    
    private let viewModel: GenderSelectViewModel
    
    private let disposeBag = DisposeBag()
    
    private let genderSelectedSubject = PublishSubject<String>()
    private var genderButtons: [SelectButton] = []
    private var genders: [String] = []
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 3.0 / 7.0
        progressBar.tintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별이 어떻게 되시나요?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "적절한 미션 추전에 필요해요! 외부에 공개되지 않아요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let genderButtonsStackView: UIStackView = {
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
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    
    // MARK: - Init
    init(viewModel: GenderSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(backButton)
        view.addSubview(stackView)
        view.addSubview(titleLabelStackView)
        view.addSubview(genderButtonsStackView)
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
        
        genderButtonsStackView.anchor(
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
    // MARK: - Binding ViewModel
    private func bindViewModel() {
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        
        let input = GenderSelectViewModel.Input(
            genderSelected: genderSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 성별 받아 버튼 생성
        output.genders
            .drive(onNext: { [weak self] genders in
                self?.genders = genders
                self?.createGenderButtons(with: genders)
            })
            .disposed(by: disposeBag)
        
        
        // 선택된 성별 처리
        output.selectedGender
            .drive(onNext: { [weak self] selectedGender in
                guard let self = self else { return }
                
                self.genderButtons.enumerated().forEach { index, button in
                    let isSelected = self.genders[index] == selectedGender
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedGender
            .map{ $0 != nil }
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
                self?.nextButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
    }
    
    private func createGenderButtons(with genders: [String]) {
        genderButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        genderButtons.removeAll()
        
        genders.forEach { gender in
            let button = SelectButton()
            button.setTitle(gender, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            button.rx.tap
                .map{ gender }
                .bind(to: genderSelectedSubject)
                .disposed(by: disposeBag)
            
            genderButtons.append(button)
            genderButtonsStackView.addArrangedSubview(button)
            
        }
        
    }
}
