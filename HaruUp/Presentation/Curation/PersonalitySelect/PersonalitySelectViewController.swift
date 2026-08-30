//
//  PersonalitySelectViewController.swift
//  HaruUp
//

import UIKit
import RxSwift
import RxCocoa

/// 캐릭터 인사 이후, 챗봇 시작 전에 AI 성격을 고르는 화면.
/// 여기서 고른 성격은 큐레이션 꼬리질문의 말투에만 반영된다.
final class PersonalitySelectViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: PersonalitySelectViewModel
    private let disposeBag = DisposeBag()

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let selectionSubject = PublishSubject<Int>()

    /// 선택지는 서버에서 받아 그릴 때 만든다
    private var optionButtons: [SelectButton] = []

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background_gradation.png")
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let style = FontStyle(font: Typography.title2.font, lineHeight: 1.38)
        label.setStyle(style, text: "어떤 방식으로\n도와드릴까요?")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body1, text: "선택한 성격에 맞춰 질문을 드려요.")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .neutral600
        return label
    }()

    private let optionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("다음", for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.backgroundColor = .cta
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        return btn
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let iv = UIActivityIndicatorView(style: .medium)
        iv.hidesWhenStopped = true
        return iv
    }()

    // MARK: - Init
    init(viewModel: PersonalitySelectViewModel) {
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
        viewDidLoadSubject.onNext(())
    }

    // MARK: - Helpers
    private func setupUI() {
        view.insertSubview(backgroundImageView, at: 0)

        [titleLabel, subtitleLabel, optionStackView, nextButton, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        backgroundImageView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )

        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 100,
            paddingLeft: 20,
            paddingRight: 20
        )

        subtitleLabel.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 12,
            paddingLeft: 20,
            paddingRight: 20
        )

        optionStackView.anchor(
            top: subtitleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 48,
            paddingLeft: 20,
            paddingRight: 20
        )

        loadingIndicator.centerX(inView: view)
        loadingIndicator.anchor(top: optionStackView.bottomAnchor, paddingTop: 24)

        nextButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 10,
            paddingRight: 20,
            height: 56
        )
    }

    private func bindViewModel() {
        let input = PersonalitySelectViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            personalitySelected: selectionSubject.asObservable(),
            nextButtonTapped: nextButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.personalities
            .drive(onNext: { [weak self] personalities in
                self?.renderOptions(personalities)
            })
            .disposed(by: disposeBag)

        output.selectedIndex
            .drive(onNext: { [weak self] selected in
                guard let self = self else { return }
                for (index, button) in self.optionButtons.enumerated() {
                    button.setSelected(index == selected)
                }
            })
            .disposed(by: disposeBag)

        output.isNextEnabled
            .drive(onNext: { [weak self] enabled in
                self?.nextButton.isEnabled = enabled
                self?.nextButton.alpha = enabled ? 1.0 : 0.4
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }

    /// 서버에서 받은 선택지로 버튼을 다시 만든다.
    private func renderOptions(_ personalities: [PersonalityData]) {
        optionStackView.arrangedSubviews.forEach {
            optionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        optionButtons.removeAll()

        for (index, personality) in personalities.enumerated() {
            let button = SelectButton()
            button.setTitle(personality.label, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 64).isActive = true

            button.rx.tap
                .map { index }
                .bind(to: selectionSubject)
                .disposed(by: disposeBag)

            optionStackView.addArrangedSubview(button)
            optionButtons.append(button)
        }
    }
}
