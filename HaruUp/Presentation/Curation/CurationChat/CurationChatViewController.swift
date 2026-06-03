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
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let suggestionSubject = PublishSubject<String>()
    private let editSubject = PublishSubject<UUID>()

    private var characterImageName: String = "haru_level1"
    private var displayItems: [ChatDisplayItem] = []

    // MARK: - UI Components

    private let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.iconXmark, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.backgroundColor = .clear
        tv.keyboardDismissMode = .interactive
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // 입력 영역
    private let inputContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()

    private let inputSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .neutral50
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let inputTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = .neutral300
        tv.text = "답변을 입력해주세요"
        tv.font = Typography.body1.font
        tv.backgroundColor = .clear
        tv.layer.cornerRadius = 20
        tv.clipsToBounds = true
        tv.returnKeyType = .send
        
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 44)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let sendButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.iconButtonGray, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var inputContainerBottomConstraint: NSLayoutConstraint?
    private var inputTextViewHeightConstraint: NSLayoutConstraint?
    
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
        view.backgroundColor = .neutral10
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupUI()
        setupTableView()
        bindViewModel()
        setupKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.onNext(())
    }

    // MARK: - Setup UI

    private func setupUI() {
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 140)
        inputTextViewHeightConstraint?.isActive = true
        // 상단 X 버튼
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // 입력 영역
        view.addSubview(inputContainerView)
        NSLayoutConstraint.activate([
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let bottomConstraint = inputContainerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor
        )
        bottomConstraint.isActive = true
        inputContainerBottomConstraint = bottomConstraint

        inputContainerView.addSubview(inputSeparator)
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(sendButton)

        inputTextView.delegate = self

        NSLayoutConstraint.activate([
            inputSeparator.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            inputSeparator.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            inputSeparator.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            inputSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -20),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 20),
            inputTextView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 20),
            inputTextView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -8),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -20),
//            inputTextView.heightAnchor.constraint(equalToConstant: 140)
        ])

        // 채팅 테이블뷰
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.register(BotMessageCell.self, forCellReuseIdentifier: BotMessageCell.identifier)
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: UserMessageCell.identifier)
        tableView.register(SuggestionChipsCell.self, forCellReuseIdentifier: SuggestionChipsCell.identifier)
        tableView.dataSource = self
    }

    private func setupAvatarHeader(imageName: String) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        headerView.backgroundColor = .clear

        let avatarImageView = UIImageView()
        avatarImageView.image = UIImage(named: imageName)
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 24
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = .primaryBlue50
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48)
        ])

        tableView.tableHeaderView = headerView
    }

    // MARK: - Bind ViewModel

    private func bindViewModel() {
        let input = CurationChatViewModel.Input(
            viewDidAppear: viewDidAppearSubject.asObservable(),
            sendButtonTapped: sendSubject.asObservable(),
            suggestionTapped: suggestionSubject.asObservable(),
        )
        let output = viewModel.transform(input: input)

        // 캐릭터 이미지 → 헤더 아바타 설정
        output.characterImageName
            .drive(onNext: { [weak self] imageName in
                self?.characterImageName = imageName
                self?.setupAvatarHeader(imageName: imageName)
            })
            .disposed(by: disposeBag)

        // displayItems 업데이트
        output.displayItems
            .drive(onNext: { [weak self] items in
                self?.displayItems = items
                self?.tableView.reloadData()
                self?.scrollToBottom()
            })
            .disposed(by: disposeBag)

        // 완료 시 입력 비활성화
        output.isCompleted
            .drive(onNext: { [weak self] completed in
                if completed {
                    self?.inputTextView.isEditable = false
                    self?.sendButton.isEnabled = false
                    self?.inputTextView.text = "완료되었습니다"
                    self?.inputTextView.textColor = .lightGray
                }
            })
            .disposed(by: disposeBag)

        // 프리필 텍스트 (칩 탭 또는 수정하기)
        output.prefillText
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] text in
                guard let textView = self?.inputTextView else { return }
                
                self?.inputTextView.text = text
                self?.inputTextView.textColor = .black
                self?.inputTextView.becomeFirstResponder()
                
                self?.sendButton.setImage(.iconButtonBlue, for: .normal)
                self?.textViewDidChange(textView)
            })
            .disposed(by: disposeBag)

        // 전송 버튼
        sendButton.rx.tap
            // 전송 버튼 중복 클릭 방지 (0.6초 이내 연타 무시)
            .throttle(.milliseconds(600), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.sendMessage()
            })
            .disposed(by: disposeBag)

        // 닫기 버튼
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showExitModal()
            })
            .disposed(by: disposeBag)
    }

    private func sendMessage() {
        let text = inputTextView.text ?? ""
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              text != "답변을 입력해주세요" else {
            return
        }
        
        sendButton.isEnabled = false
        
        sendSubject.onNext(text.trimmingCharacters(in: .whitespacesAndNewlines))
        inputTextView.text = "답변을 입력해주세요"
        inputTextView.textColor = .neutral300
        
        sendButton.setImage(.iconButtonGray, for: .normal)
        inputTextView.resignFirstResponder()
        
        // 잠시 후 버튼 다시 활성화 (필요 시)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.sendButton.isEnabled = true
        }
    }
    
    private func showExitModal() {
        let modalVC = ExitConfirmModalViewController()
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        modalVC.onRestartTapped = { [weak self] in
            self?.viewModel.restartChat()
            self?.inputTextView.text = "답변을 입력해주세요"
            self?.inputTextView.textColor = .neutral300
            self?.sendButton.setImage(.iconButtonGray, for: .normal)
            self?.view.endEditing(true)
        }
        present(modalVC, animated: true)
    }

    private func scrollToBottom() {
        guard !displayItems.isEmpty else { return }
        let indexPath = IndexPath(row: displayItems.count - 1, section: 0)
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

        let keyboardHeight = keyboardFrame.height
        
        // 1. 바닥 위치 조정
        inputContainerBottomConstraint?.constant = -keyboardHeight
        
        // 2. 텍스트뷰 높이 조정 
        inputTextViewHeightConstraint?.constant = 80

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }

        scrollToBottom()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        // 1. 바닥 위치 복구
        inputContainerBottomConstraint?.constant = 0
        // 2. 텍스트뷰 높이 복구 (100 -> 140)
        inputTextViewHeightConstraint?.constant = 140
        
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
        return displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayItems[indexPath.row]

        switch item {
        case .botMessage(let message):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BotMessageCell.identifier, for: indexPath
            ) as? BotMessageCell else {
                return UITableViewCell()
            }
            cell.configure(
                text: message.text,
                highlightedText: message.highlightedText,
                subtitleText: message.subtitleText,
                isShimmering: message.isShimmering
            )
            return cell

        case .userMessage(let message):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserMessageCell.identifier, for: indexPath
            ) as? UserMessageCell else {
                return UITableViewCell()
            }
            cell.configure(text: message.text, onEdit: nil)
            return cell

        case .suggestionChips(let suggestions):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SuggestionChipsCell.identifier, for: indexPath
            ) as? SuggestionChipsCell else {
                return UITableViewCell()
            }
            cell.configure(suggestions: suggestions) { [weak self] text in
                self?.suggestionSubject.onNext(text)
            }
            return cell
        }
    }
}

// MARK: - UITextViewDelegate
extension CurationChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .neutral300 {
            textView.text = nil
            textView.textColor = .appBlack
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "답변을 입력해주세요"
            textView.textColor = .neutral300
            sendButton.setImage(.iconButtonGray, for: .normal)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.setImage(hasText ? .iconButtonBlue : .iconButtonGray, for: .normal)
        
        let range = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(range)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendMessage()
            return false
        }
        return true
    }
}
