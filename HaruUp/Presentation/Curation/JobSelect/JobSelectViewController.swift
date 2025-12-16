//
//  JobSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/16/25.
//

import UIKit

class JobSelectViewController: UIViewController {
    
    private let viewModel: JobSelectViewModel
    
    init(viewModel: JobSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .magenta
    }
    

}
