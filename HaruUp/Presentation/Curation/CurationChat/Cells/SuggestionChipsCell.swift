//
//  SuggestionChipsCell.swift
//  HaruUp
//
//  Created by 조영현 on 4/6/26.
//

import UIKit

// MARK: - Suggestion Chips Cell
final class SuggestionChipsCell: UITableViewCell {
    static let identifier = "SuggestionChipsCell"

    private var suggestions: [String] = []
    private var onChipTapped: ((String) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(ChipCollectionCell.self, forCellWithReuseIdentifier: ChipCollectionCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(collectionView)
        collectionView.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor,
            right: contentView.rightAnchor,
            paddingTop: 4,
            paddingBottom: 8,
            height: 40
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        suggestions = []
        onChipTapped = nil
    }

    func configure(suggestions: [String], onChipTapped: ((String) -> Void)?) {
        self.suggestions = suggestions
        self.onChipTapped = onChipTapped
        collectionView.reloadData()
    }
}

extension SuggestionChipsCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChipCollectionCell.identifier, for: indexPath
        ) as? ChipCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: suggestions[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onChipTapped?(suggestions[indexPath.item])
    }
}
