//
//  BirthSelectViewController.swift
//  HaruUp
//
//  Created by 하다현 on 12/17/25.
//

import UIKit
import RxSwift
import RxCocoa

class BirthSelectViewController: UIViewController {
    
    private let viewModel: BirthSelectViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(viewModel: BirthSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - setupUI
    private func setupUI() {
        view.backgroundColor = .red
    }

}
