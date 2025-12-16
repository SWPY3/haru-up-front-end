//
//  GenderSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit

class GenderSelectViewController: UIViewController {

    private let viewModel: GenderSelectViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    init(viewModel: GenderSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
