//
//  GoalInputSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

class GoalInputSelectViewController: UIViewController {
    private let viewModel: GoalInputSelectViewModel
    
    private let disposeBag = DisposeBag()
    
    private let goalInputSubject = PublishSubject<String>()
    private var currentGoalInput: String = ""
    
    let curationData: CurationData
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 8.0 / 8.0
        progressBar.tintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "찾는 목표가 없으신가요?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심사에 맞는 원하는 목표를 알려주세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 선택된 관심사 표시 라벨
    private let selectedInterestLabel: UILabel = {
        let label = UILabel()
//        label.text = "선택한 관심사 : "
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "2~15자로 입력해주세요."
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    
    init(viewModel: GoalInputSelectViewModel, curationData: CurationData) {
        self.viewModel = viewModel
        self.curationData = curationData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        
        textField.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        
        textFieldContainer.addSubview(textField)
        view.addSubview(textFieldContainer)
        view.addSubview(backButton)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(progressBar)
        stackView.addArrangedSubview(titleLabelStackView)
        
        view.addSubview(selectedInterestLabel)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        
        view.addSubview(nextButton)
        
        
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
        
        selectedInterestLabel.anchor(
            top: subtitleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 10,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        textFieldContainer.anchor(
            top: selectedInterestLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 30,
            paddingLeft: 30,
            paddingRight: 30,
            height: 50
        )
        
        textField.anchor(
            top: textFieldContainer.topAnchor,
            left: textFieldContainer.leftAnchor,
            bottom: textFieldContainer.bottomAnchor,
            right: textFieldContainer.rightAnchor,
            paddingLeft: 16,
            paddingRight: 16
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
        
        selectedInterestLabel.text = "선택한 관심사 : \(curationData.interest ?? "")"
    }
    
    private func bindViewModel() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.currentGoalInput = text.trimmingCharacters(in: .whitespaces)
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .bind(to: goalInputSubject)
            .disposed(by: disposeBag)
        
        let input = GoalInputSelectViewModel.Input(
            goalInput: goalInputSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 15자 제한
        output.formattedGoal
            .drive(textField.rx.text)
            .disposed(by: disposeBag)
        
        // 버튼 활성화 (2~15자)
        output.isValid
            .drive(onNext: { [weak self] isValid in
                self?.nextButton.isEnabled = isValid
                self?.nextButton.alpha = isValid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
    }
    
    
}
