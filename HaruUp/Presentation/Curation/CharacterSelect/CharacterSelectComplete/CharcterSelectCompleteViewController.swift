//
//  CharacterSelectCompleteViewController.swift
//  HaruUp
//
//  Created by 하다현 on 4/15/26.
//


import UIKit
import RxSwift
import RxCocoa

class CharacterSelectCompleteViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CharacterSelectCompleteViewModel
    private let disposeBag = DisposeBag()
    
    
    
    
    // MARK: - Init
    init(viewModel: CharacterSelectCompleteViewModel) {
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
