//
//  JobDetailSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa


class JobDetailSelectViewController: UIViewController {
    private let viewModel: JobDetailSelectViewModel
    private let disposeBag = DisposeBag()
    
    private let jobDetailSelectedSubject = PublishSubject<String>()
    private var jobDetailButtons: [SelectButton] = []
    private var jobDetails: [String] = []
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 2.0 / 7.0
        progressBar.tintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "세부 직무를 골라주세요."
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "적절한 관심사를 추천하기 위해 필요해요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let jobDetailButtonsStackView: UIStackView = {
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
        return button
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 20
        return sv
    }()
    
    private let titleLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 4
        return sv
    }()
    
    // MARK: - Init
    
    init(viewModel: JobDetailSelectViewModel) {
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
        view.addSubview(stackView)
        view.addSubview(titleLabelStackView)
        view.addSubview(scrollView)
        view.addSubview(nextButton)
        
        stackView.addArrangedSubview(progressBar)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        stackView.addArrangedSubview(titleLabelStackView)
        scrollView.addSubview(contentView)
        contentView.addSubview(jobDetailButtonsStackView)
        
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
        nextButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20,
            height: 56
        )
        
        scrollView.anchor(
            top: stackView.bottomAnchor,
            left: view.leftAnchor,
            bottom: nextButton.topAnchor,
            right: view.rightAnchor,
            paddingTop: 56,
            paddingLeft: 30,
            paddingBottom: 20,
            paddingRight: 30
        )
        
        contentView.anchor(
            top: scrollView.topAnchor,
            left: scrollView.leftAnchor,
            bottom: scrollView.bottomAnchor,
            right: scrollView.rightAnchor,
            
        )
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        jobDetailButtonsStackView.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor,
            right: contentView.rightAnchor,
            
        )
        
        
        
    }
    
    private func bindViewModel() {
        let input = JobDetailSelectViewModel.Input(
            jobDetailSelected: jobDetailSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 세부 직무 목록 받아서 버튼 생성
        output.jobDetails
            .drive(onNext: { [weak self] jobDetails in
                self?.jobDetails = jobDetails
                self?.createJobDetailButtons(with: jobDetails)
            })
            .disposed(by: disposeBag)
        
        // 선택된 세부 직무에 따라 버튼 상태 업데이트
        output.selectedJobDetail
            .drive(onNext: { [weak self] selectedJobDetail in
                guard let self = self else { return }
                
                self.jobDetailButtons.enumerated().forEach { index, button in
                    let isSelected = self.jobDetails[index] == selectedJobDetail
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
    }
    private func createJobDetailButtons(with jobDetails: [String]) {
        jobDetailButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        jobDetailButtons.removeAll()
        
        jobDetails.forEach { jobDetail in
            let button = SelectButton()
            button.setTitle(jobDetail, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            button.rx.tap
                .map { jobDetail }
                .bind(to: jobDetailSelectedSubject)
                .disposed(by: disposeBag)
            
            jobDetailButtons.append(button)
            jobDetailButtonsStackView.addArrangedSubview(button)
        }
    }
    
    
}
