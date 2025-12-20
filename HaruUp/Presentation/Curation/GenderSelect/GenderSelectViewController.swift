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
        button.setImage(UIImage(named: "chevron_left.png"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 4.0 / 8.0
        progressBar.tintColor = .primaryBlue700
        progressBar.trackTintColor = .neutral50
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "성별이 어떻게 되시나요?")
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "적절한 미션 추전에 필요해요! 외부에 공개되지 않아요.")
        label.textAlignment = .left
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
        button.setImage(UIImage(named: "next_btn_gray.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        button.isEnabled = false
        return button
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
    
        view.addSubview(genderButtonsStackView)
        view.addSubview(nextButton)
        
        stackView.addArrangedSubview(progressBar)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        stackView.addArrangedSubview(titleLabelStackView)
        
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
        
        genderButtonsStackView.anchor(
            top: stackView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 56,
            paddingLeft: 20,
            paddingRight: 20
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
                let imageName = isEnabled ? "next_btn_blue" : "next_btn_gray"
                self?.nextButton.setImage(UIImage(named: imageName), for: .normal)
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
