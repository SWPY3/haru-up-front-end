//
//  HistoryViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

class HistoryViewController: UIViewController {
    
    // MARK: - Properties
    private var currentDate = Date()
    private var calendarData: HistoryModel.CalendarData?
    private var selectedDay: Int?
    
    private let viewModel: HistoryViewModel
    
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
    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        setupUI()
    
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
            let missions = calendarData?.dailyMissions[day] ?? []
            let hasAttendance = !missions.isEmpty
            let missionCount = missions.count
            let isSpecial = calendarData?.specialDays.contains(day) ?? false
            
            cell.configure(day: day, isSelected: isSelected, isToday: isToday, hasAttendance: hasAttendance, missionCount: missionCount, isSpecial: isSpecial)
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
        if indexPath.item >= firstWeekday {
            let day = indexPath.item - firstWeekday + 1
            selectedDay = day
            updateMissionCard()
            collectionView.reloadData()
        }
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
