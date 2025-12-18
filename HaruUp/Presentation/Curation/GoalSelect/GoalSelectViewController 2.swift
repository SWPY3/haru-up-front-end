//
//  GoalSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa


class GoalSelectViewController: UIViewController {
    private let viewModel: GoalSelectViewModel
    
    private let disposeBag = DisposeBag()
    
    
    private let goalSelectedSubject = PublishSubject<String>()
    private var goalButtons: [SelectButton] = []
    private var goals: [String] = []
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 7.0 / 7.0
        progressBar.tintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "목표는 무엇인가요?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "목표를 1개 골라주세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goalButtonsStackView: UIStackView = {
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
    
    init(viewModel: GoalSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        bindViewmodel()
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(stackView)
        view.addSubview(goalButtonsStackView)
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
        
        goalButtonsStackView.anchor(
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
    
    
    // MARK: - BindViewModel
    private func bindViewmodel() {
        backButton.rx.tap
            .subscribe(onNext: { [ weak self ] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let input = GoalSelectViewModel.Input(
            goalSelected: goalSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        
        output.goals
            .drive(onNext: { [weak self] goals in
                self?.goals = goals
                self?.createGoalButtons(with: goals)
            })
            .disposed(by: disposeBag)
        
        output.selectedGoal
            .drive(onNext: { [weak self] selectedGoal in
                guard let self = self else { return }
                
                self.goalButtons.enumerated().forEach { index, button in
                    let isSelected = self.goals[index] == selectedGoal
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화
        output.selectedGoal
            .map{ $0 != nil }
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
                self?.nextButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
    }
    
    private func createGoalButtons(with interestDetails: [String]) {
        goalButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        goalButtons.removeAll()
        
        goals.forEach { goal in
            let button = SelectButton()
            button.setTitle(goal, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            button.rx.tap
                .map { goal }
                .bind(to: goalSelectedSubject)
                .disposed(by: disposeBag)
            
            goalButtons.append(button)
            goalButtonsStackView.addArrangedSubview(button)
        }
    }
    

}
