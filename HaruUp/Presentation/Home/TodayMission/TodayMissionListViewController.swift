//
//  TodayMissionListViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/10/25.
//

import UIKit

class TodayMissionListViewController: UIViewController {
    
    private let viewModel: TodayMissionListViewModel
    
    init(viewModel: TodayMissionListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
    }
}
