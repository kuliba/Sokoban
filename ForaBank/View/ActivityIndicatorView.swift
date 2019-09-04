//
//  ActivityIndicatorView.swift
//  ForaBank
//
//  Created by Sergey on 16/01/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {

    private(set) public var isAnimating: Bool = false
    
    public func startAnimation() {
        guard !isAnimating else {
            return
        }
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setUpAnimation()
    }
    public final func stopAnimating() {
        guard isAnimating else {
            return
        }
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }
    
    func setUpAnimation() {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        let lineWidth: CGFloat = 5
        path.addArc(withCenter: CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2),
                    radius: self.frame.size.width / 2 - lineWidth / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = tintColor.cgColor
        layer.lineWidth = lineWidth
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = self.bounds
        
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        #if swift(>=4.2)
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        #else
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        #endif
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        #if swift(>=4.2)
        groupAnimation.fillMode = .forwards
        #else
        groupAnimation.fillMode = kCAFillModeForwards
        #endif
        
        layer.add(groupAnimation, forKey: "animation")
        self.layer.addSublayer(layer)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
