//
//  RegistrationViewController.swift
//  HaruUp
//
//  Created by 하다현 on 11/27/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: HomeViewModel
    
    // MARK: - LifeCycle
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()   
    }
    
    // MARK: - Selectors
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .brown
    }
}
