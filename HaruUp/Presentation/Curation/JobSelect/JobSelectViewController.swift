//
//  JobSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit
import RxSwift
import RxCocoa

class JobSelectViewController: UIViewController {
    
    private let viewModel: JobSelectViewModel
    
    private let disposeBag = DisposeBag()
    
    private let jobSelectedSubject = PublishSubject<String>()
    private var jobButtons: [JobSelectButton] = []
    
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 1.0 / 7.0
        progressBar.tintColor = .blue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 어떤 일을 하고 계신가요?"
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
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let jobButtonsStackView: UIStackView = {
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
    
    init(viewModel: JobSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupUI()
        bindViewModel()
    }
    

    // MARK: - Setup UI
    func setupUI() {
        view.addSubview(stackView)
        view.addSubview(titleLabelStackView)
        view.addSubview(jobButtonsStackView)
        view.addSubview(nextButton)
        
        stackView.addArrangedSubview(progressBar)
        
        titleLabelStackView.addArrangedSubview(titleLabel)
        titleLabelStackView.addArrangedSubview(subtitleLabel)
        
        stackView.addArrangedSubview(titleLabelStackView)
        
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
        
        jobButtonsStackView.anchor(
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
        let input = JobSelectViewModel.Input(
            jobSelected: jobSelectedSubject.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        // 직업 목록 받아 버튼 생성
        output.jobs
            .drive(onNext: { [weak self] jobs in
                self?.createJobButtons(with: jobs)
            })
            .disposed(by: disposeBag)
        
        // 선택된 직업 처리
        output.selectedJob
            .drive(onNext: {[weak self] selectedJob in
                self?.updateButtonSelection(selectedJob: selectedJob)
            })
            .disposed(by: disposeBag)
    }
    
    private func createJobButtons(with jobs: [String]) {
        jobs.forEach { job in
            let button = JobSelectButton()
            button.setTitle(job, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            button.rx.tap
                .map{ job }
                .bind(to: jobSelectedSubject)
                .disposed(by: disposeBag)
            
            jobButtons.append(button)
            jobButtonsStackView.addArrangedSubview(button)
        }
    }
    
     private func updateButtonSelection(selectedJob: String?) {
         print("=== 선택된 직업: \(selectedJob ?? "없음") ===")
         jobButtons.forEach { button in
             let buttonTitle = button.titleLabel?.text
             let isSelected = buttonTitle == selectedJob
             print("버튼 '\(buttonTitle ?? "")' -> \(isSelected ? "선택" : "해제")")
             button.setSelected(isSelected)
         }
    }
    
}
