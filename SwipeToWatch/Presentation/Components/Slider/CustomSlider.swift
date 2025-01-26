//
//  CustomSlider.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//


import UIKit

protocol CustomSliderDelegate: AnyObject {
    func touchPointDidChange(yDifference: CGFloat)
}

class CustomSlider: UISlider {
    // MARK: - Public Properties -
    
    weak var delegate: CustomSliderDelegate?
    
    var initialTouchPoint: CGPoint = .zero
    var yDifference: CGFloat = 0
    
    // MARK: - Overrides -
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // Store the initial touch point when tracking begins
        initialTouchPoint = touch.location(in: self)
        return super.beginTracking(touch, with: event)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // Get the current touch point
        let currentTouchPoint = touch.location(in: self)
        
        // Calculate the difference in Y position
        let yDifference = initialTouchPoint.y - currentTouchPoint.y
        self.yDifference = yDifference
        delegate?.touchPointDidChange(yDifference: yDifference)
        
        return super.continueTracking(touch, with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        // Reset the initial touch point
        initialTouchPoint = .zero
        yDifference = 0
        super.endTracking(touch, with: event)
    }
}
