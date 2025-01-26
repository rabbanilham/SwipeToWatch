//
//  UIView+Extension.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
    
    func fadeIn(
        to alpha: CGFloat = 1.0,
        _ duration: TimeInterval = 0.15,
        delay: TimeInterval = 0.0,
        completion: @escaping ((Bool) -> Void) = { (finished: Bool) -> Void in }
    ) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: { self.alpha = alpha },
            completion: completion
        )
    }
    
    func fadeOut(
        _ duration: TimeInterval = 0.15,
        delay: TimeInterval = 0.0,
        completion: @escaping (Bool) -> Void = { (finished: Bool) -> Void in }
    ) {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: UIView.AnimationOptions.curveEaseIn,
                animations: {
                    self.alpha = 0.0
                },
                completion: completion
            )
        }
    }
}
