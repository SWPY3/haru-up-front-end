//
//  RecommendViewController.swift
//  HaruUp
//
//  Created by 조영현 on 12/5/25.
//

import UIKit

class RecommendViewController: UIViewController {
    
    private let viewModel: RecommendViewModel
    
    init(viewModel: RecommendViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
    }
}
