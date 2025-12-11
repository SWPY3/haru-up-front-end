//
//  TodayMissionIntroViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class TodayMissionIntroViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: TodayMissionIntroViewModel
    var onSelectMissionTap: (() -> Void)?
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("list", for: .normal)
        button.backgroundColor = .green
        
        return button
    }()
    
    init(viewModel: TodayMissionIntroViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        configureNextButton()
        bind()
    }
    
    private func configureNextButton() {
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        nextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                print("미션 목록 화면으로 이동")
                self.onSelectMissionTap?()
            }.disposed(by: disposeBag)
    }
}
