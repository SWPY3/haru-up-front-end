//
//  CurationChatViewController.swift
//  HaruUp
//
//  Created on 2026/03/30.
//

import UIKit
import RxSwift
import RxCocoa

final class CurationChatViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CurationChatViewModel
    private let disposeBag = DisposeBag()

    private let sendSubject = PublishSubject<String>()
    private let startSubject = PublishSubject<Void>()

    private var characterImageName: String = "haru_level1"
    private var messages: [ChatMessage] = []
    private var hasStarted = false

    // MARK: - UI Components

    private let progressBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = .cta
        pv.trackTintColor = .neutral100
        pv.progress = 0
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    private let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        ), for: .normal)
        btn.tintColor = .neutral800
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.backgroundColor = .white
        tv.keyboardDismissMode = .interactive
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // 시작 화면 컨테이너
    private let startContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let startCharacterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let startGreetingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let startButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("시작하기", for: .normal)
        btn.titleLabel?.font = Typography.subtitle2.font
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .cta
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 입력 영역
    private let inputContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let inputSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .neutral100
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "답변..."
        tf.font = Typography.body1.font
        tf.borderStyle = .none
        tf.backgroundColor = .neutral50
        tf.layer.cornerRadius = 20
        tf.clipsToBounds = true
        tf.returnKeyType = .send

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 0))
        tf.rightView = rightPadding
        tf.rightViewMode = .always

        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up")?.withConfiguration(config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .cta
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var inputContainerBottomConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(viewModel: CurationChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupUI()
        setupTableView()
        bindViewModel()
        setupKeyboardObservers()
    }

    // MARK: - Setup UI

    private func setupUI() {
        // 상단 바 (X 버튼 + 프로그레스 바)
        view.addSubview(closeButton)
        view.addSubview(progressBar)

        closeButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            width: 32,
            height: 32
        )

        progressBar.anchor(
            left: closeButton.rightAnchor,
            right: view.rightAnchor,
            paddingLeft: 12,
            paddingRight: 16,
            height: 4
        )
        progressBar.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true

        // 시작 화면
        view.addSubview(startContainerView)
        startContainerView.anchor(
            top: closeButton.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 8
        )

        startContainerView.addSubview(startGreetingLabel)
        startContainerView.addSubview(startCharacterImageView)
        startContainerView.addSubview(startButton)

        startGreetingLabel.anchor(
            left: startContainerView.leftAnchor,
            right: startContainerView.rightAnchor,
            paddingLeft: 40,
            paddingRight: 40
        )
        startGreetingLabel.centerYAnchor.constraint(
            equalTo: startContainerView.centerYAnchor, constant: -100
        ).isActive = true

        startCharacterImageView.anchor(
            top: startGreetingLabel.bottomAnchor,
            paddingTop: 24,
            width: 140,
            height: 140
        )
        startCharacterImageView.centerXAnchor.constraint(
            equalTo: startContainerView.centerXAnchor
        ).isActive = true

        startButton.anchor(
            left: startContainerView.leftAnchor,
            bottom: startContainerView.safeAreaLayoutGuide.bottomAnchor,
            right: startContainerView.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 10,
            paddingRight: 20,
            height: 56
        )

        // 채팅 영역
        view.addSubview(tableView)
        tableView.anchor(
            top: closeButton.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 8
        )
        tableView.isHidden = true

        // 입력 영역
        view.addSubview(inputContainerView)
        inputContainerView.anchor(
            top: tableView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor
        )

        let bottomConstraint = inputContainerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        )
        bottomConstraint.isActive = true
        inputContainerBottomConstraint = bottomConstraint

        inputContainerView.addSubview(inputSeparator)
        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendButton)

        inputSeparator.anchor(
            top: inputContainerView.topAnchor,
            left: inputContainerView.leftAnchor,
            right: inputContainerView.rightAnchor,
            height: 1
        )

        inputTextField.anchor(
            top: inputSeparator.bottomAnchor,
            left: inputContainerView.leftAnchor,
            bottom: inputContainerView.bottomAnchor,
            right: inputContainerView.rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingBottom: 8,
            paddingRight: 16,
            height: 40
        )

        sendButton.anchor(
            right: inputTextField.rightAnchor,
            paddingRight: 4,
            width: 32,
            height: 32
        )
        sendButton.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor).isActive = true

        inputContainerView.isHidden = true
    }

    private func setupTableView() {
        tableView.register(BotMessageCell.self, forCellReuseIdentifier: BotMessageCell.identifier)
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: UserMessageCell.identifier)
        tableView.dataSource = self
    }

    // MARK: - Bind ViewModel

    private func bindViewModel() {
        let input = CurationChatViewModel.Input(
            startButtonTapped: startSubject.asObservable(),
            sendButtonTapped: sendSubject.asObservable()
        )
        let output = viewModel.transform(input: input)

        // 캐릭터 정보 바인딩
        output.characterName
            .drive(onNext: { [weak self] name in
                self?.startGreetingLabel.setStyle(
                    Typography.body1,
                    text: "안녕하세요! 저는 \(name)예요.\n여러분에게 가장 적합한 커리큘럼을 설계하기 위해 몇 가지 간단한 질문을 드릴게요."
                )
            })
            .disposed(by: disposeBag)

        output.characterImageName
            .drive(onNext: { [weak self] imageName in
                self?.characterImageName = imageName
                self?.startCharacterImageView.image = UIImage(named: imageName)
            })
            .disposed(by: disposeBag)

        // 시작 버튼
        startButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.hasStarted = true
                self?.startContainerView.isHidden = true
                self?.tableView.isHidden = false
                self?.inputContainerView.isHidden = false
                self?.startSubject.onNext(())
            })
            .disposed(by: disposeBag)

        // 메시지 업데이트
        output.messages
            .drive(onNext: { [weak self] msgs in
                self?.messages = msgs
                self?.tableView.reloadData()
                self?.scrollToBottom()
            })
            .disposed(by: disposeBag)

        // 프로그레스 바 업데이트
        output.currentQuestionIndex
            .drive(onNext: { [weak self] index in
                guard index >= 0 else { return }
                let progress = Float(index + 1) / 6.0
                UIView.animate(withDuration: 0.3) {
                    self?.progressBar.setProgress(progress, animated: true)
                }
            })
            .disposed(by: disposeBag)

        // 완료 시 입력 비활성화
        output.isCompleted
            .drive(onNext: { [weak self] completed in
                if completed {
                    self?.inputTextField.isEnabled = false
                    self?.sendButton.isEnabled = false
                    self?.inputTextField.placeholder = "완료되었습니다"
                }
            })
            .disposed(by: disposeBag)

        // 전송 버튼
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.sendMessage()
            })
            .disposed(by: disposeBag)

        // 리턴 키로 전송
        inputTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.sendMessage()
            })
            .disposed(by: disposeBag)

        // 닫기 버튼
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func sendMessage() {
        guard let text = inputTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        sendSubject.onNext(text)
        inputTextField.text = ""
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - Keyboard

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputContainerBottomConstraint?.constant = -keyboardHeight

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }

        scrollToBottom()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        inputContainerBottomConstraint?.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource

extension CurationChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        switch message.type {
        case .bot:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BotMessageCell.identifier, for: indexPath
            ) as? BotMessageCell else {
                return UITableViewCell()
            }
            cell.configure(text: message.text, characterImageName: characterImageName)
            return cell

        case .user:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserMessageCell.identifier, for: indexPath
            ) as? UserMessageCell else {
                return UITableViewCell()
            }
            cell.configure(text: message.text)
            return cell
        }
    }
}

// MARK: - Bot Message Cell

final class BotMessageCell: UITableViewCell {
    static let identifier = "BotMessageCell"

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.backgroundColor = .primaryBlue50
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .neutral50
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .neutral800
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        avatarImageView.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            width: 40,
            height: 40
        )

        bubbleView.anchor(
            top: contentView.topAnchor,
            left: avatarImageView.rightAnchor,
            bottom: contentView.bottomAnchor,
            paddingTop: 8,
            paddingLeft: 8,
            paddingBottom: 4
        )
        bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7
        ).isActive = true

        messageLabel.anchor(
            top: bubbleView.topAnchor,
            left: bubbleView.leftAnchor,
            bottom: bubbleView.bottomAnchor,
            right: bubbleView.rightAnchor,
            paddingTop: 12,
            paddingLeft: 14,
            paddingBottom: 12,
            paddingRight: 14
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, characterImageName: String) {
        messageLabel.setStyle(Typography.body4, text: text)
        messageLabel.textColor = .neutral800
        avatarImageView.image = UIImage(named: characterImageName)
    }
}

// MARK: - User Message Cell

final class UserMessageCell: UITableViewCell {
    static let identifier = "UserMessageCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .cta
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        bubbleView.anchor(
            top: contentView.topAnchor,
            bottom: contentView.bottomAnchor,
            right: contentView.rightAnchor,
            paddingTop: 8,
            paddingBottom: 4,
            paddingRight: 16
        )
        bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7
        ).isActive = true

        messageLabel.anchor(
            top: bubbleView.topAnchor,
            left: bubbleView.leftAnchor,
            bottom: bubbleView.bottomAnchor,
            right: bubbleView.rightAnchor,
            paddingTop: 12,
            paddingLeft: 14,
            paddingBottom: 12,
            paddingRight: 14
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        messageLabel.setStyle(Typography.body4, text: text)
        messageLabel.textColor = .white
    }
}
