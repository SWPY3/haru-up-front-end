//
//  MissionBottomSheetViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/26/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MissionBottomSheetViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: MissionBottomSheetViewModel
    
    var onMissionStatusChanged: (() -> Void)?
    
    private var bottomSheetViewBottomConstraint: NSLayoutConstraint?
    private let bottomSheetHeight: CGFloat = 223
    
    private var deleteViewBottomConstraint: NSLayoutConstraint?
    private let deleteSheetHeight: CGFloat = 260
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .bottomSheetBackground
        
        return view
    }()
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "영어 회화 유튜브 강의 10분...")
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var completeButton = createActionButton(
        title: "미션 완료",
        icon: .iconMissionComplete
    )
    
    private lazy var deleteButton = createActionButton(
        title: "미션 삭제",
        icon: .iconMissionDelete
    )
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [completeButton, deleteButton])
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillEqually
        
        return stack
    }()
    
    private lazy var missionCompleteView: MissionCompleteView = {
        let view = MissionCompleteView()
        view.alpha = 0
        
        return view
    }()
    
    private lazy var missionDeleteView: MissionDeleteView = {
        let view = MissionDeleteView()
        
        return view
    }()
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmedViewTap))
    
    init(viewModel: MissionBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
        
        setAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }
    
    private func setupView() {
        configureBackgroundView()
        configureTitle()
        configureButton()
        configureMissionCompleteView()
        configureMissionDeleteView()
    }
    
    private func configureBackgroundView(){
        view.backgroundColor = .clear
        
        [dimmedView, bottomSheetView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.heightAnchor.constraint(equalToConstant: bottomSheetHeight)
        ])
        
        bottomSheetViewBottomConstraint = bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomSheetHeight)
        bottomSheetViewBottomConstraint?.isActive = true
    }
    
    private func configureTitle() {
        bottomSheetView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureButton() {
        bottomSheetView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bottomSheetView.bottomAnchor.constraint(lessThanOrEqualTo: bottomSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            buttonStackView.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -20),
            
            completeButton.heightAnchor.constraint(equalToConstant: 54),
            deleteButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func configureMissionCompleteView() {
        view.addSubview(missionCompleteView)
        missionCompleteView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            missionCompleteView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            missionCompleteView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            missionCompleteView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 28),
            missionCompleteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)
        ])
    }
    
    private func configureMissionDeleteView() {
        view.addSubview(missionDeleteView)
        missionDeleteView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            missionDeleteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            missionDeleteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            missionDeleteView.heightAnchor.constraint(equalToConstant: deleteSheetHeight)
        ])
        
        deleteViewBottomConstraint = missionDeleteView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: deleteSheetHeight
        )
        deleteViewBottomConstraint?.isActive = true
    }
    
    private func bind() {
        let trackedCompleteTap = completeButton.rx.tap
            .do(onNext: { _ in
                AnalyticsManager.shared.track(event: AppEvent.Home.completeMissionTapped)
            }).asObservable()
        
        let trackedDeleteTap = missionDeleteView.deleteButton.rx.tap
            .do(onNext: { _ in
                AnalyticsManager.shared.track(event: AppEvent.Home.confirmDeleteTapped)
            }).asObservable()
        
        let input = MissionBottomSheetViewModel.Input(
            completeTap: trackedCompleteTap,
            deleteTap: trackedDeleteTap
        )
        
        let output = viewModel.transform(input: input)
        
        output.missionTitle
            .drive(onNext: { [weak self] title in
                self?.titleLabel.setStyle(Typography.subtitle1, text: title)
            })
            .disposed(by: disposeBag)
        
        output.missionExp
            .drive(onNext: { [weak self] exp in
                self?.missionCompleteView.configure(exp: exp)
            })
            .disposed(by: disposeBag)
        
        output.complete
            .emit(onNext: { [weak self] _ in
                // 완료 했을 때 Notification 전달
                NotificationCenter.default.post(name: .missionCompleted, object: nil)
                self?.showCompleteView()
                
                self?.onMissionStatusChanged?()
            })
            .disposed(by: disposeBag)
        
        output.dismiss
            .emit(onNext: { [weak self] in
                self?.hideBottomSheet()
                
                self?.onMissionStatusChanged?()
            })
            .disposed(by: disposeBag)
    }
    
    private func createActionButton(title: String, icon: UIImage) -> UIButton {
        var config = UIButton.Configuration.plain()
        var titleContainer = AttributeContainer()
        titleContainer.font = Typography.body1.font
        config.attributedTitle = AttributedString(title, attributes: titleContainer)
        config.image = icon
        config.imagePadding = 12
        config.baseForegroundColor = .neutral1000
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        
        return button
    }
    
    private func setAction() {
        dimmedView.addGestureRecognizer(tapGesture)
        
        missionCompleteView.confirmButton.addTarget(self, action: #selector(handleCompleteButtonTap), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector(showDeleteView), for: .touchUpInside)
        missionDeleteView.cancelButton.addTarget(self, action: #selector(hideDeleteView), for: .touchUpInside)
    }
    
    @objc private func handleDimmedViewTap() {
        hideBottomSheet()
    }
    
    @objc private func handleCompleteButtonTap() {
        self.dismiss(animated: false)
    }
    
    private func showBottomSheet() {
        UIView.animate(withDuration: 0.25) {
            self.dimmedView.alpha = 1 // 설정한 색상이 보이게 됨
        }
        
        self.bottomSheetViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideBottomSheet(completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: 0.25) {
            self.dimmedView.alpha = 0
        }
        
        self.bottomSheetViewBottomConstraint?.constant = bottomSheetHeight
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    private func showCompleteView() {
        tapGesture.isEnabled = false
        
        self.bottomSheetViewBottomConstraint?.constant = bottomSheetHeight
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.missionCompleteView.alpha = 1.0
        }
    }
    
    @objc private func showDeleteView() {
        view.layoutIfNeeded()
        
        AnalyticsManager.shared.track(event: AppEvent.Home.deleteMissionTapped)

        bottomSheetViewBottomConstraint?.constant = bottomSheetHeight   // 내려가기
        deleteViewBottomConstraint?.constant = 0                        // 올라오기

        UIView.animate(withDuration: 0.30, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func hideDeleteView() {
        view.layoutIfNeeded()

        AnalyticsManager.shared.track(event: AppEvent.Home.cancelDeleteTapped)
        
        deleteViewBottomConstraint?.constant = deleteSheetHeight
        bottomSheetViewBottomConstraint?.constant = 0

        UIView.animate(withDuration: 0.30, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }

}
