//
//  MyPageViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa



class MyPageViewController: UIViewController {
    
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    // Coordinator 연결용
    var onEditInterest: (() -> Void)?
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "마이페이지")
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView(image: .characterProfile) // 실제 에셋명으로 변경
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        //        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let jobLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .neutral900
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // GOAL 카드
    private let goalCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let goalBadge: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "GOAL")
        label.textColor = .white
        label.backgroundColor = .primaryBlue600
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goalNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let interestTag = MyPageTagView()
    private let detailTag = MyPageTagView()
    
    // 메뉴 리스트 스택 (버튼 5개)
    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.layer.cornerRadius = 14
        stack.clipsToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let editInterestBtn = MyPageMenuButton(title: "관심사 수정")
    private let feedbackBtn = MyPageMenuButton(title: "피드백하기")   // 변경됨
    private let inquiryBtn = MyPageMenuButton(title: "문의하기")      // 추가됨
    private let logoutBtn = MyPageMenuButton(title: "로그아웃", hasArrow: false)
    private let withdrawBtn = MyPageMenuButton(title: "탈퇴하기", hasArrow: false, isDestructive: true)
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral700
        label.setStyle(Typography.body4, text: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .neutral10
        
        [titleLabel, profileImageView, nicknameLabel, jobLabel, goalCardView, menuStackView, versionLabel].forEach {
            view.addSubview($0)
        }
        
        [goalBadge, goalNameLabel, interestTag, detailTag].forEach {
            goalCardView.addSubview($0)
        }
        
        [editInterestBtn, feedbackBtn, inquiryBtn, logoutBtn, withdrawBtn].forEach {
            menuStackView.addArrangedSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 10),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            
            jobLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 4),
            jobLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            
            goalCardView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30),
            goalCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            goalCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goalCardView.heightAnchor.constraint(equalToConstant: 140),
            
            goalBadge.topAnchor.constraint(equalTo: goalCardView.topAnchor, constant: 20),
            goalBadge.leadingAnchor.constraint(equalTo: goalCardView.leadingAnchor, constant: 20),
            
            goalNameLabel.topAnchor.constraint(equalTo: goalBadge.bottomAnchor, constant: 10),
            goalNameLabel.leadingAnchor.constraint(equalTo: goalBadge.leadingAnchor),
            
            interestTag.topAnchor.constraint(equalTo: goalNameLabel.bottomAnchor, constant: 12),
            interestTag.leadingAnchor.constraint(equalTo: goalBadge.leadingAnchor),
            
            detailTag.centerYAnchor.constraint(equalTo: interestTag.centerYAnchor),
            detailTag.leadingAnchor.constraint(equalTo: interestTag.trailingAnchor, constant: 8),
            
            menuStackView.topAnchor.constraint(equalTo: goalCardView.bottomAnchor, constant: 24),
            menuStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            menuStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            versionLabel.topAnchor.constraint(equalTo: menuStackView.bottomAnchor, constant: 20),
            versionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25)
        ])
    }
    
    private func bind() {
        let input = MyPageViewModel.Input(
            viewDidLoad: Observable.just(()),
            editInterestTapped: editInterestBtn.rx.tap,
            feedbackTapped: feedbackBtn.rx.tap,
            inquiryTapped: inquiryBtn.rx.tap,
            logoutTapped: logoutBtn.rx.tap,
            withdrawTapped: withdrawBtn.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.curationData
            .drive(onNext: { [weak self] data in
                self?.nicknameLabel.text = data.nickname
                self?.jobLabel.text = data.jobDetail?.jobDetailName
                self?.goalNameLabel.text = data.goal?.name
                self?.interestTag.configure(text: data.interest?.name ?? "", emoji: Interest.iconForInterest(name: data.interest?.name ?? ""))
                self?.detailTag.configure(text: data.interestDetail?.name ?? "")
                print("닉네임: \(data.nickname ?? "없음")")
                print("세부직업: \(data.jobDetail?.jobDetailName ?? "없음")")
            })
            .disposed(by: disposeBag)
        
        output.appVersion
            .drive(versionLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 버튼 클릭 바인딩
        editInterestBtn.rx.tap
            .subscribe(onNext: { [weak self] in self?.onEditInterest?() })
            .disposed(by: disposeBag)
    }
}
