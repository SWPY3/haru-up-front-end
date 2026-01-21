//
//  HistoryViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {
    
    // MARK: - Properties
    private var currentDate = Date()
    private var calendarData: HistoryModel.CalendarData?
    private var selectedDay: Int?
    private var dailyMissions: [DailyMission] = []
    
    private let viewModel: HistoryViewModel
    private let disposeBag = DisposeBag()
    
    // Subjects for Input
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let monthChangedRelay = BehaviorRelay<Date>(value: Date())
    private let daySelectedRelay = PublishRelay<(day: Int, hasCompleted: Bool)>()
    
    // MARK: - UI Components
    private let viewTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.title3, text: "나의 기록")
        label.textColor = .black
        
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        
        return stackView
    }()
    
    // MARK: - Calendar UI
    private let calendarCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        
        return view
    }()
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.subtitle1.font
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    private let prevButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .iconCalendarChevronLeft
        config.baseForegroundColor = .neutral800
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10) // (44 - 24) / 2
        
        let button = UIButton(configuration: config)
        
        return button
    }()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .iconCalendarChevronRight
        config.baseForegroundColor = .neutral300
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let button = UIButton(configuration: config)
        
        return button
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        
        return stack
    }()
    
    private var attendanceValueLabel: UILabel!
    private var missionValueLabel: UILabel!
    
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 40)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
        collectionView.register(CalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarHeaderView.identifier)
        
        return collectionView
    }()
    
    private var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - 미션 정보 UI
    private let missionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        
        return view
    }()
    
    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "1월 1일 완료한 미션")
        label.textColor = .black
        
        return label
    }()
    
    private let missionContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        
        return stackView
    }()
    
    private let emptyMissionView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconCalendarEmpty
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle2, text: "완료한 미션이 없어요")
        label.textColor = .neutral600
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: - 차트 UI
    private let chartCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        
        return view
    }()
    
    private let chartTitleLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.subtitle1, text: "성장차트")
        label.textColor = .black
        
        return label
    }()
    
    private let chartDescriptionLabel: UILabel = {
        let label = UILabel()
        label.setStyle(Typography.body4, text: "5개월간 얼마나 자주 방문했는지 비교해볼 수 있어요.")
        label.textColor = .neutral500
        
        return label
    }()
    
    private lazy var chartView: UIView = {
        let view = GrowthChartViewFactory.create()
        
        return view
    }()
    
    // MARK: - Init
    init(viewModel: HistoryViewModel) {
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
        setupActions()
        updateMonthYearLabel()
        selectToday()
        
        bindViewModel()
        viewDidLoadRelay.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCalendarHeight()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .neutral10
        
        setupTitle()
        setupScrollView()
        setupCalendarCard()
        setupMissionCard()
        setupChartCard()
    }
    
    private func setupTitle() {
        view.addSubview(viewTitleLabel)
        viewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 33),
            viewTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: viewTitleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func setupCalendarCard() {
        contentStackView.addArrangedSubview(calendarCardView)
        
        // Stats views
        let (attendanceView, attLabel) = createStatView(title: "출석일", value: "0", unit: "일")
        let (missionView, missLabel) = createStatView(title: "완료한 미션", value: "0", unit: "개")
        attendanceValueLabel = attLabel
        missionValueLabel = missLabel
        statsStackView.addArrangedSubview(attendanceView)
        statsStackView.addArrangedSubview(missionView)
        
        [prevButton, monthYearLabel, nextButton, statsStackView, calendarCollectionView].forEach {
            calendarCardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        calendarHeightConstraint = calendarCollectionView.heightAnchor.constraint(equalToConstant: 300)
        
        NSLayoutConstraint.activate([
            prevButton.topAnchor.constraint(equalTo: calendarCardView.topAnchor, constant: 16),
            prevButton.leadingAnchor.constraint(equalTo: calendarCardView.leadingAnchor, constant: 24),
            prevButton.widthAnchor.constraint(equalToConstant: 44),
            prevButton.heightAnchor.constraint(equalToConstant: 44),
            
            monthYearLabel.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor),
            monthYearLabel.centerXAnchor.constraint(equalTo: calendarCardView.centerXAnchor),
            
            nextButton.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: calendarCardView.trailingAnchor, constant: -24),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            statsStackView.topAnchor.constraint(equalTo: prevButton.bottomAnchor, constant: 8),
            statsStackView.leadingAnchor.constraint(equalTo: calendarCardView.leadingAnchor, constant: 24),
            statsStackView.trailingAnchor.constraint(equalTo: calendarCardView.trailingAnchor, constant: -24),
            
            calendarCollectionView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 34),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarCardView.leadingAnchor, constant: 28),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarCardView.trailingAnchor, constant: -28),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calendarCardView.bottomAnchor, constant: -20),
            calendarHeightConstraint
        ])
    }
    
    private func setupMissionCard() {
        contentStackView.addArrangedSubview(missionCardView)
        
        [missionTitleLabel, missionContentStackView].forEach {
            missionCardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [emptyImageView, emptyLabel].forEach {
            emptyMissionView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            emptyImageView.topAnchor.constraint(equalTo: emptyMissionView.topAnchor, constant: 12),
            emptyImageView.centerXAnchor.constraint(equalTo: emptyMissionView.centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 56),
            emptyImageView.heightAnchor.constraint(equalToConstant: 56),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 2),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyMissionView.centerXAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyMissionView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            missionTitleLabel.topAnchor.constraint(equalTo: missionCardView.topAnchor, constant: 24),
            missionTitleLabel.leadingAnchor.constraint(equalTo: missionCardView.leadingAnchor, constant: 24),
            missionTitleLabel.trailingAnchor.constraint(equalTo: missionCardView.trailingAnchor, constant: -24),
            
            missionContentStackView.topAnchor.constraint(equalTo: missionTitleLabel.bottomAnchor),
            missionContentStackView.leadingAnchor.constraint(equalTo: missionCardView.leadingAnchor, constant: 24),
            missionContentStackView.trailingAnchor.constraint(equalTo: missionCardView.trailingAnchor, constant: -24),
            missionContentStackView.bottomAnchor.constraint(equalTo: missionCardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupChartCard() {
        contentStackView.addArrangedSubview(chartCardView)
        
        [chartTitleLabel, chartDescriptionLabel, chartView].forEach {
            chartCardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        GrowthChartViewFactory.configure(chartView, with: [
            ("8월", 8),
            ("9월", 15),
            ("10월", 12),
            ("11월", 25),
            ("12월", 28)
        ], highlightLast: true)
        
        NSLayoutConstraint.activate([
            chartTitleLabel.topAnchor.constraint(equalTo: chartCardView.topAnchor, constant: 28),
            chartTitleLabel.leadingAnchor.constraint(equalTo: chartCardView.leadingAnchor, constant: 24),
            
            chartDescriptionLabel.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor),
            chartDescriptionLabel.leadingAnchor.constraint(equalTo: chartCardView.leadingAnchor, constant: 24),
            chartDescriptionLabel.trailingAnchor.constraint(equalTo: chartCardView.trailingAnchor, constant: -24),
            
            chartView.topAnchor.constraint(equalTo: chartDescriptionLabel.bottomAnchor, constant: 10),
            chartView.leadingAnchor.constraint(equalTo: chartCardView.leadingAnchor, constant: 24),
            chartView.trailingAnchor.constraint(equalTo: chartCardView.trailingAnchor, constant: -24),
            chartView.bottomAnchor.constraint(equalTo: chartCardView.bottomAnchor, constant: -24),
            chartView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    // MARK: - bind
    private func bindViewModel() {
        let input = HistoryViewModel.Input(
            viewDidLoad: viewDidLoadRelay.asObservable(),
            monthChanged: monthChangedRelay.asObservable(),
            daySelected: daySelectedRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 월 타이틀 바인딩
        output.monthTitle
            .drive(monthYearLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 출석일 바인딩
        output.attendanceDays
            .map { "\($0)" }
            .drive(attendanceValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 완료한 미션 수 바인딩
        output.completedMissions
            .map { "\($0)" }
            .drive(missionValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 캘린더 데이터 바인딩
        output.dailyMissions
            .drive(onNext: { [weak self] missions in
                self?.dailyMissions = missions
                self?.calendarCollectionView.reloadData()
                self?.selectTodayOrFirst()
            })
            .disposed(by: disposeBag)
        
        // 선택된 날짜의 상세 미션 바인딩
        output.selectedDayMissions
            .drive(onNext: { [weak self] missions in
                self?.updateMissionCard(with: missions)
            })
            .disposed(by: disposeBag)
        
        // 상세 미션 로딩 상태
        output.isMissionLoading
            .drive(onNext: { [weak self] isLoading in
                self?.updateMissionCardLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        // 캘린더 로딩 상태
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                isLoading ? self?.showLoading() : self?.hideLoading()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] message in
                self?.showError(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func setupActions() {
        prevButton.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
    }
    
    @objc private func prevMonthTapped() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateMonthYearLabel()
            selectedDay = 1
            updateMissionCard()
            calendarCollectionView.reloadData()
            updateCalendarHeight()
        }
    }
    
    @objc private func nextMonthTapped() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateMonthYearLabel()
            selectedDay = 1
            updateMissionCard()
            calendarCollectionView.reloadData()
            updateCalendarHeight()
        }
    }
    
    // MARK: - Helper Methods
    // 출석일 및 완료한 미션 View
    private func createStatView(title: String, value: String, unit: String) -> (UIView, UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.setStyle(Typography.body4, text: title)
        titleLabel.textColor = .neutral900
        titleLabel.textAlignment = .center
        
        let valueLabel = UILabel()
        valueLabel.setStyle(Typography.head2, text: value)
        valueLabel.textColor = .cta
        
        let unitLabel = UILabel()
        unitLabel.setStyle(Typography.caption2, text: unit)
        unitLabel.textColor = .neutral600
        
        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 6
        valueStack.alignment = .lastBaseline
        
        [titleLabel, valueStack].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            valueStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return (container, valueLabel)
    }
    
    private func updateCalendarHeight() {
        let cellWidth = (calendarCollectionView.frame.width) / 7
        let numberOfRows = ceil(Double(numberOfDaysInMonth() + firstWeekdayOfMonth()) / 7.0)
        let headerHeight: CGFloat = 40
        let height = (cellWidth * CGFloat(numberOfRows)) + headerHeight
        
        if calendarHeightConstraint.constant != height && height > 0 {
            calendarHeightConstraint.constant = height
            view.layoutIfNeeded()
        }
    }
    
    private func updateMonthYearLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        monthYearLabel.text = formatter.string(from: currentDate)
    }
    
    private func selectToday() {
        let calendar = Calendar.current
        let today = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        if currentComponents.year == todayComponents.year && currentComponents.month == todayComponents.month {
            selectedDay = todayComponents.day
        } else {
            selectedDay = 1
        }
        
        updateMissionCard()
    }
    
    private func updateMissionCard() {
        guard let day = selectedDay else { return }
        
        let titleText: String = "\(Calendar.current.component(.month, from: currentDate))월 \(day)일 완료한 미션"
        missionTitleLabel.setStyle(Typography.subtitle1, text: titleText)
        
        missionContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let missions = calendarData?.dailyMissions[day] ?? []
        
        if missions.isEmpty {
            missionContentStackView.addArrangedSubview(emptyMissionView)
        } else {
            for (index, mission) in missions.enumerated() {
                let missionView = createMissionItemView(mission: mission)
                missionContentStackView.addArrangedSubview(missionView)
                
                if index < missions.count - 1 {
                    let separator = createSeparator()
                    missionContentStackView.addArrangedSubview(separator)
                }
            }
        }
    }
    
    // MARK: Create UI Helpers
    // 완료한 미션 목록에 들어가는 각 view
    private func createMissionItemView(mission: HistoryModel.Mission) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.setStyle(Typography.body1, text: mission.title)
        titleLabel.textColor = .neutral900
        titleLabel.numberOfLines = 0
        
        let badgeStackView = UIStackView()
        badgeStackView.axis = .horizontal
        badgeStackView.spacing = 8
        
        let difficultyBadge = MissionDifficultyBadgeView()
        let expBadge = MissionExpBadgeView()
        
        difficultyBadge.configure(difficulty: mission.difficulty)
        expBadge.configure(exp: mission.exp)
        
        badgeStackView.addArrangedSubview(difficultyBadge)
        badgeStackView.addArrangedSubview(expBadge)
        
        [titleLabel, badgeStackView].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            badgeStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            badgeStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            badgeStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        
        return container
    }
    
    // 완료한 미션 목록의 Line
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .neutral50
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    // MARK: - Calendar Helpers
    private func numberOfDaysInMonth() -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: currentDate)!
        return range.count
    }
    
    private func firstWeekdayOfMonth() -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let firstDay = Calendar.current.date(from: components)!
        let weekday = Calendar.current.component(.weekday, from: firstDay)
        return weekday == 1 ? 6 : weekday - 2
    }
    
    // MARK: - Helper Methods
    private func updateCalendar(with missions: [DailyMission]) {
        // 캘린더 CollectionView 업데이트
        print("mission: \(missions)")
        
        self.dailyMissions = missions
        
        // 출석일 계산 (completedCount > 0인 날 수)
        let attendanceDays = missions.filter { $0.hasCompleted }.count
        attendanceValueLabel.text = "\(attendanceDays)"
        
        // 완료한 미션 총 개수
        let totalMissions = missions.reduce(0) { $0 + $1.completedCount }
        missionValueLabel.text = "\(totalMissions)"
        
        calendarCollectionView.reloadData()
        updateMissionCardFromDailyMissions()
    }
    
    private func updateMissionCardFromDailyMissions() {
        guard let day = selectedDay else { return }
        
        let month = Calendar.current.component(.month, from: currentDate)
        let titleText = "\(month)월 \(day)일 완료한 미션"
        missionTitleLabel.setStyle(Typography.subtitle1, text: titleText)
        
        missionContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 선택된 날짜의 미션 데이터 찾기
        let missionForDay = dailyMissions.first { $0.day == day }
        let missionCount = missionForDay?.completedCount ?? 0
        
        if missionCount == 0 {
            missionContentStackView.addArrangedSubview(emptyMissionView)
        } else {
            // 미션 개수만 표시하거나, 상세 정보가 필요하면 별도 API 호출
            let summaryLabel = UILabel()
            summaryLabel.setStyle(Typography.body1, text: "완료한 미션 \(missionCount)개")
            summaryLabel.textColor = .neutral900
            missionContentStackView.addArrangedSubview(summaryLabel)
        }
    }
    
    private func updateMissionTitle(for day: Int) {
        let month = Calendar.current.component(.month, from: currentDate)
        let titleText = "\(month)월 \(day)일 완료한 미션"
        missionTitleLabel.setStyle(Typography.subtitle1, text: titleText)
    }
    
    private func updateMissionCard(with missions: [HistoryModel.Mission]) {
        missionContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if missions.isEmpty {
            missionContentStackView.addArrangedSubview(emptyMissionView)
        } else {
            for (index, mission) in missions.enumerated() {
                let missionView = createMissionItemView(mission: mission)
                missionContentStackView.addArrangedSubview(missionView)
                
                if index < missions.count - 1 {
                    let separator = createSeparator()
                    missionContentStackView.addArrangedSubview(separator)
                }
            }
        }
    }
    
    private func updateMissionCardLoading(_ isLoading: Bool) {
        if isLoading {
            missionContentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // 로딩 인디케이터 표시
            let loadingIndicator = UIActivityIndicatorView(style: .medium)
            loadingIndicator.startAnimating()
            
            let container = UIView()
            container.addSubview(loadingIndicator)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                loadingIndicator.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
                loadingIndicator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -40)
            ])
            
            missionContentStackView.addArrangedSubview(container)
        }
    }
    
    private func selectTodayOrFirst() {
        let calendar = Calendar.current
        let today = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        let day: Int
        if currentComponents.year == todayComponents.year && currentComponents.month == todayComponents.month {
            day = todayComponents.day ?? 1
        } else {
            day = 1
        }
        
        selectedDay = day
        
        let missionForDay = dailyMissions.first { $0.day == day }
        let hasCompleted = missionForDay?.hasCompleted ?? false
        
        updateMissionTitle(for: day)
        
        if !hasCompleted {
            updateMissionCard(with: [])
        }
        
        daySelectedRelay.accept((day: day, hasCompleted: hasCompleted))
        calendarCollectionView.reloadData()
    }
    
    private func showLoading() {
        // 로딩 표시
    }
    
    private func hideLoading() {
        // 로딩 숨김
    }
    
    private func showError(message: String) {
        // 에러 알림 표시
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDaysInMonth() + firstWeekdayOfMonth()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as! CalendarCell
        
        let firstWeekday = firstWeekdayOfMonth()
        
        if indexPath.item < firstWeekday {
            cell.configure(day: nil, isSelected: false, isToday: false, hasAttendance: false, missionCount: 0, isSpecial: false)
        } else {
            let day = indexPath.item - firstWeekday + 1
            let isToday = isDateToday(day: day)
            let isSelected = day == selectedDay
            
            // dailyMissions에서 해당 날짜 데이터 찾기
            let missionForDay = dailyMissions.first { $0.day == day }
            let hasAttendance = missionForDay?.hasCompleted ?? false
            let missionCount = missionForDay?.completedCount ?? 0
            let isSpecial = missionCount >= 3  // 예: 3개 이상 완료 시 특별 표시
            
            cell.configure(
                day: day,
                isSelected: isSelected,
                isToday: isToday,
                hasAttendance: hasAttendance,
                missionCount: missionCount,
                isSpecial: isSpecial
            )
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalendarHeaderView.identifier, for: indexPath)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstWeekday = firstWeekdayOfMonth()
        guard indexPath.item >= firstWeekday else { return }
        
        let day = indexPath.item - firstWeekday + 1
        selectedDay = day
        
        // 해당 날짜의 완료 여부 확인
        let missionForDay = dailyMissions.first { $0.day == day }
        let hasCompleted = missionForDay?.hasCompleted ?? false
        
        // 미션 타이틀 업데이트
        updateMissionTitle(for: day)
        
        // 완료된 미션이 없으면 빈 상태 UI 표시
        if !hasCompleted {
            updateMissionCard(with: [])
        }
        
        // ViewModel에 선택 이벤트 전달
        daySelectedRelay.accept((day: day, hasCompleted: hasCompleted))
        
        collectionView.reloadData()
    }
    
    private func isDateToday(day: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        return currentComponents.year == todayComponents.year &&
        currentComponents.month == todayComponents.month &&
        day == todayComponents.day
    }
}
