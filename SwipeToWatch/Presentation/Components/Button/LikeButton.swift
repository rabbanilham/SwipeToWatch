//
//  LikeButton.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import UIKit

final class LikeButton: FeedButton {
    private var isLiked = false
    private var likes: Int = 0
    
    override func handleButtonTapped() {
        super.handleButtonTapped()
        toggleLiked(to: !isLiked)
    }
    
    override func configure(image: UIImage? = nil, text: String? = nil) {
        super.configure(image: image, text: text)
        likes = Int(text ?? "0") ?? 0
    }
    
    func toggleLiked(to isLiked: Bool) {
        self.isLiked = isLiked
        if isLiked {
            likes += 1
            configure(image: UIImage(systemName: "heart.fill")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal), text: "\(likes)")
        } else {
            likes -= 1
            configure(image: UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal), text: "\(likes)")
        }
    }
}
