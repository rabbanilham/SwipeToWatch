//
//  FeedButton.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import SnapKit
import UIKit

// MARK: - FeedButtonDelegate -

protocol FeedButtonDelegate: AnyObject {
    func didTapButton(_ button: FeedButton)
}

class FeedButton: UIView {
    // MARK: - Public Properties -
    
    weak var delegate: FeedButtonDelegate?
    
    // MARK: - UI Properties -
    
    internal lazy var buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    internal lazy var buttonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 1
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
    
    // MARK: - Functions -
    
    func configure(image: UIImage? = nil, text: String? = nil) {
        if let image = image {
            buttonImageView.image = image
        }
        if let text = text {
            buttonLabel.text = text
        }
    }
    
    func handleButtonTapped() {
        delegate?.didTapButton(self)
    }
}

private extension FeedButton {
    func configureUI() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapButton)))
        
        addSubviews(buttonImageView, buttonLabel)
        buttonImageView.snp.makeConstraints { make in
            make.height.width.equalTo(30)
            make.top.width.equalToSuperview()
        }
        buttonLabel.snp.makeConstraints { make in
            make.top.equalTo(buttonImageView.snp.bottom).offset(4)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    @objc
    func didTapButton() {
        handleButtonTapped()
    }
}
