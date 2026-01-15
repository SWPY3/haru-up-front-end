//
//  AgreeViewController.swift
//  HaruUp
//
//  Created by 하다현 on 1/15/26.
//

import UIKit
import RxSwift
import RxCocoa

class AgreeViewController: UIViewController {
    
    private let viewModel: AgreeViewModel
    private let disposeBag = DisposeBag()
    
    var onTermDetailRequest: ((String) -> Void)?
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.chevronLeft, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title2, text: "하루업 이용을 위해\n이용약관 동의가 필요해요")
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    // 전체 동의 뷰
    private let allAgreeRow = AgreementCell(title: "모두 동의합니다", font:Typography.subtitle2.font, hasArrow: false)
    
    // 구분선
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        return view
    }()
    
    
    // 개별 항목 뷰들
    private let term1Row = AgreementCell(title: "[필수] 서비스 이용약관에 동의합니다", font: Typography.body4.font, hasArrow: true)
    private let term2Row = AgreementCell(title: "[필수] 개인정보 수집 및 이용에 동의합니다",font: Typography.body4.font, hasArrow: true)
    private let term3Row = AgreementCell(title: "[필수] 만 14세 이상입니다", font: Typography.body4.font, hasArrow: false)
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("동의하기", for: .normal)
        button.titleLabel?.font = Typography.subtitle2.font
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .neutral200
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()
    
    private lazy var termsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [allAgreeRow, separatorView, term1Row, term2Row, term3Row])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    init(viewModel: AgreeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다음 화면에서도 커스텀 네비게이션을 쓴다면 false로 유지해도 됩니다.
        // navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    
    private func setupLayout() {
        [backButton, titleLabel, termsStackView, confirmButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            // Back Button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Terms Stack View
            termsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            termsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            termsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Separator Height (StackView 내부)
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // Confirm Button
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func bind() {
        // 1. Input 생성
        let input = AgreeViewModel.Input(
            allCheckTap: allAgreeRow.checkButtonTap.asObservable(),
            term1CheckTap: term1Row.checkButtonTap.asObservable(),
            term2CheckTap: term2Row.checkButtonTap.asObservable(),
            term3CheckTap: term3Row.checkButtonTap.asObservable(),
            term1DetailTap: term1Row.arrowButtonTap.asObservable(),
            term2DetailTap: term2Row.arrowButtonTap.asObservable(),
            confirmButtonTapped: confirmButton.rx.tap.asObservable()
        )
        
        // 2. Output 바인딩
        let output = viewModel.transform(input: input)
        // 체크박스 상태 업데이트 UI 바인딩
        output.isAllChecked
            .drive(onNext: { [weak self] isChecked in
                self?.allAgreeRow.setChecked(isChecked)
            })
            .disposed(by: disposeBag)
        
        output.isTerm1Checked
            .drive(onNext: { [weak self] isChecked in
                self?.term1Row.setChecked(isChecked)
            })
            .disposed(by: disposeBag)
        
        output.isTerm2Checked
            .drive(onNext: { [weak self] isChecked in
                self?.term2Row.setChecked(isChecked)
            })
            .disposed(by: disposeBag)
        
        output.isTerm3Checked
            .drive(onNext: { [weak self] isChecked in
                self?.term3Row.setChecked(isChecked)
            })
            .disposed(by: disposeBag)
        
        // 버튼 활성화 상태 바인딩
        output.isConfirmButtonEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.confirmButton.isEnabled = isEnabled
                self?.confirmButton.backgroundColor = isEnabled ? .cta : .neutral200
            })
            .disposed(by: disposeBag)
        
        output.navigateToWeb
            .emit(onNext: { [weak self] urlString in
                guard let self = self, !urlString.isEmpty else { return }
                // Coordinator로 URL 전달
                self.onTermDetailRequest?(urlString)
            })
            .disposed(by: disposeBag)
        
        output.didTapConfirm
            .emit(onNext: { [weak self] in
                self?.onFinish?()
            })
            .disposed(by: disposeBag)
        
        // 뒤로가기 버튼 (Coordinator로 처리하지 않고 단순 pop이라면)
        backButton.rx.tap
            .bind { [weak self] in
                self?.onBack?()
            }
            .disposed(by: disposeBag)
    }
}
