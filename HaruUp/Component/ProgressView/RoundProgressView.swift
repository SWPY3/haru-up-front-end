//
//  RoundProgressView.swift
//  HaruUp
//
//  Created by 조영현 on 12/19/25.
//

import UIKit

final class RoundedProgressView: UIView {
    
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.neutral50.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBlue700
        
        return view
    }()
    
    /// 진행률 (0.0 ~ 1.0)
    var progress: CGFloat = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    private var progressWidthConstraint: NSLayoutConstraint? /// 채워지는 효과를 위해 사용
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = self.frame.height / 2
        
        trackView.layer.cornerRadius = radius
        progressView.layer.cornerRadius = radius
        
        updateProgress()
    }
    
    private func setupView() {
        configureTrackView()
        configureProgressView()
    }
    
    private func configureTrackView() {
        self.addSubview(trackView)
        trackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: self.topAnchor),
            trackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            trackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func configureProgressView() {
        self.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor)
        ])
        
        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        progressWidthConstraint?.isActive = true
    }
    
    private func updateProgress() {
        // 전체 너비 * 진행률 = 파란색 바의 너비
        let targetWidth = self.frame.width * progress
        progressWidthConstraint?.constant = targetWidth
        self.layoutIfNeeded()
    }
    
    // 색상 설정을 위한 편의 메서드
    func setColors(trackTintColor: UIColor, trackBorderColor: UIColor, progressColor: UIColor) {
        trackView.backgroundColor = trackTintColor
        trackView.layer.borderColor = trackBorderColor.cgColor
        progressView.backgroundColor = progressColor
    }
}
