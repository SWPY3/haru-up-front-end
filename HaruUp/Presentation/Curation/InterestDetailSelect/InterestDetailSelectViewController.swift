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
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let interestDetailSelectedSubject = PublishSubject<InterestDetail>()
    private var interestDetailButtons: [SelectButton] = []
    private var interestDetailIconButtons: [InterestButton] = []
    private var interestDetails: [InterestDetail] = []
    
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
        progressBar.progress = 7.0 / 8.0
        progressBar.tintColor = .primaryBlue700
        progressBar.trackTintColor = .neutral50
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "세부 관심사는 무엇인가요?")
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "관심사의 세부 분야를 1개 골라주세요.")
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
    
    private let interestDetailButtonsStackView: UIStackView = {
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
        
        viewDidLoadSubject.onNext(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(stackView)
        view.addSubview(interestDetailButtonsStackView)
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
        
        interestDetailButtonsStackView.anchor(
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
    
    private func bindViewModel() {
        backButton.rx.tap
            .subscribe(onNext: { [ weak self ] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let input = InterestDetailSelectViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            interestDetailSelected: interestDetailSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.isLoading
                    .drive(onNext: { [weak self] isLoading in
                        if isLoading {
                            self?.activityIndicator.startAnimating()
                            self?.interestDetailButtonsStackView.isHidden = true
                        } else {
                            self?.activityIndicator.stopAnimating()
                            self?.interestDetailButtonsStackView.isHidden = false
                        }
                    })
                    .disposed(by: disposeBag)
        
        
        
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
                    let isSelected = self.interestDetails[index].id == selectedInterestDetail?.id
                    button.setSelected(isSelected)
                }
                
                self.interestDetailIconButtons.enumerated().forEach { index, button in
                    let isSelected = self.interestDetails[index].id == selectedInterestDetail?.id
                    button.setSelected(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화
        output.selectedInterestDetail
            .map{ $0 != nil }
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
                self?.nextButton.backgroundColor = isEnabled ? .cta : .neutral200
            })
            .disposed(by: disposeBag)
    }
    
    private func createInterestDetailButtons(with interestDetails: [InterestDetail]) {
        interestDetailButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        interestDetailButtons.removeAll()
        
        interestDetails.forEach { interestDetail in
            if let interestDetailicon = interestDetail.icon {
                let button = InterestButton()
                button.configure(icon: interestDetailicon, title: interestDetail.name)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalToConstant: 56).isActive = true
                
                button.rx.tap
                    .map { interestDetail }
                    .bind(to: interestDetailSelectedSubject)
                    .disposed(by: disposeBag)
                
                interestDetailIconButtons.append(button)
                interestDetailButtonsStackView.addArrangedSubview(button)
            } else {
                let button = SelectButton()
                button.setTitle(interestDetail.name, for: .normal)
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
}
