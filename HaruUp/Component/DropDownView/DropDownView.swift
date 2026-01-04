//
//  DropDownView.swift
//  HaruUp
//
//  Created by 하다현 on 1/1/26.
//

import UIKit
import RxSwift
import RxCocoa

final class DropdownView: UIView {
    
    // 선택 이벤트 (공통 프로토콜 타입으로 전달)
    let itemSelected = PublishRelay<DropdownDisplayable>()
    private var items: [DropdownDisplayable] = []
    private var selectedId: Int?
    
    // 셀 높이 상수 정의 (55pt로 통일)
    private let rowHeight: CGFloat = 55.0
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(DropdownCell.self, forCellReuseIdentifier: "DropdownCell")
        tv.separatorStyle = .none
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 12
        tv.clipsToBounds = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.shadowColor = UIColor(red: 218/255, green: 225/255, blue: 240/255, alpha: 1.0).cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // 데이터 바인딩
    func bind(items: [DropdownDisplayable], selectedId: Int?) {
        self.items = items
        self.selectedId = selectedId
        self.tableView.reloadData()
        
        // 스크롤 가능 여부 설정 (4개 초과일 때만 스크롤)
        self.tableView.isScrollEnabled = items.count > 4
        
        // 1. 높이 계산 (셀 높이 55pt 기준)
        let contentHeight = CGFloat(items.count) * rowHeight
        
        // 4개까지 보이도록 최대 높이를 220으로 설정 (55 * 4 = 220)
        let maxHeight: CGFloat = rowHeight * 4
        
        // 실제 적용할 높이
        let finalHeight = min(contentHeight, maxHeight)
        
        // 2. 높이 제약조건 업데이트
        if let heightConstraint = self.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = finalHeight
            self.superview?.layoutIfNeeded() // 즉시 반영
        }
        
        // 3. 내용이 220보다 길면 스크롤 바 깜빡임
        if contentHeight > maxHeight {
            DispatchQueue.main.async {
                self.tableView.flashScrollIndicators()
            }
        }
//        if items.count > 4 {
//            DispatchQueue.main.async {
//                self.tableView.flashScrollIndicators()
//            }
//        }
    }
}

    extension DropdownView: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath) as? DropdownCell else { return UITableViewCell() }
            let item = items[indexPath.row]
            // ID 비교를 통해 선택 상태 확인
            let isSelected = item.id == selectedId
            cell.configure(text: item.displayName, isSelected: isSelected)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedItem = items[indexPath.row]
            itemSelected.accept(selectedItem) // 선택된 아이템 방출
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return rowHeight
        }
    }
