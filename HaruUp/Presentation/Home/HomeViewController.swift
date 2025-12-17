//
//  RegistrationViewController.swift
//  HaruUp
//
//  Created by 하다현 on 11/27/25.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: HomeViewModel
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    var onSelectTodayMission: (() -> Void)? // Coordinator와의 연결은 단순히 클로저 사용
    
    // MARK: - LifeCycle
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.onNext(())
    }
    
    private func bind() {
        let input = HomeViewModel.Input(
            viewDidAppear: viewDidAppearSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.showTodayMissionFlow
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.onSelectTodayMission?()
            })
            .disposed(by: disposeBag)
    }
    
    func configureUI() {
        view.backgroundColor = .brown
    }
}
