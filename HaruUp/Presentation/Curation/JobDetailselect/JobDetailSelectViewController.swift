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
    private var jobDetailButtons: [JobSelectButton] = []
    private var jobDetails: [String] = []
    
    private let progressBar: UIProgressView = {
            let progressBar = UIProgressView(progressViewStyle: .default)
            progressBar.progress = 2.0 / 7.0  // 2번째 화면이므로 2/7
            progressBar.tintColor = .blue
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
           label.font = .systemFont(ofSize: 15, weight: .regular)
           label.textAlignment = .left
           label.textColor = .gray
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
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
        
    }
    
    private func setupUI() {
        
    }
    
    
}
