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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Today Mission"
        label.textAlignment = .center
        
        return label
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
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
        
        setupView()
        bind()
    }
    
    private func setupView() {
        configureBackground()
        configureUI()
    }
    
    private func configureBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    private func configureUI() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, characterImageView, nextButton].forEach {
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
