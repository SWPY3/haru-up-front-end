//
//  CharacterSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/15/25.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterSelectViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CharacterSelectViewModel
    private let disposeBag = DisposeBag()
    
    private let characterSelectedSubject = PublishSubject<Int>()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "앞으로 함께 성장할\n메이트를 선택해주세요!"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let descriptionBox: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "만나서 반가워요!\n저와 함께 한결음씩 성장하며 가보실까요?"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    
    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "next_btn_gray.png"), for: .normal)
        return btn
    }()
    
    // MARK: - Init
    init(viewModel: CharacterSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    

    
    // MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .white
        
        
        descriptionBox.addSubview(subtitleLabel)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionBox)
       
        view.addSubview(nextButton)
        
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 60,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        descriptionBox.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 50,
            paddingLeft: 30,
            paddingRight: 30
        )
        
        subtitleLabel.anchor(
            top: descriptionBox.topAnchor,
            left: descriptionBox.leftAnchor,
            bottom: descriptionBox.bottomAnchor,
            right: descriptionBox.rightAnchor,
            paddingTop: 20,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20
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
        
        
        let input = CharacterSelectViewModel.Input(
            characterSelected: characterSelectedSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
    
        output.isValid
            .drive(onNext: { [weak self] isValid in
                self?.nextButton.isEnabled = isValid
                self?.nextButton.setImage(UIImage(named: "next_btn_blue"), for: .normal)
            })
            .disposed(by: disposeBag)
    }
}

