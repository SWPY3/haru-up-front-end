//
//  TodayMissionListViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class TodayMissionListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: TodayMissionListViewModel
    
    var onComplete: (() -> Void)?
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("complete", for: .normal)
        button.backgroundColor = .green
        
        return button
    }()
    
    init(viewModel: TodayMissionListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        configureNextButton()
        bind()
    }
    
    private func configureNextButton() {
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        let input = TodayMissionListViewModel.Input(
            completeTap: completeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.missionCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("미션 선택 완료 -> 홈 화면 이동")
                self?.onComplete?()
            })
            .disposed(by: disposeBag)
    }
}
