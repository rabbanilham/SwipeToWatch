//
//  FeedsErrorCell.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 26/01/2025.
//

import SnapKit
import UIKit

final class FeedsErrorCell: UICollectionViewCell {
    // MARK: - UI Properties -
    
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints({ $0.horizontalEdges.centerY.equalTo(view.layoutMarginsGuide) })
        
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emoticonLabel, titleLabel, descriptionLabel])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        
        return stackView
    }()
    
    private lazy var emoticonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36)
        label.text = "🥲"
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.text = "An error has occured"
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    // MARK: - Lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}

extension FeedsErrorCell {
    func configure(message: String) {
        descriptionLabel.text = "\(message)\n\nSimply pull down to try again."
    }
}

private extension FeedsErrorCell {
    func configureUI() {
        contentView.addSubview(mainContainerView)
        mainContainerView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}
