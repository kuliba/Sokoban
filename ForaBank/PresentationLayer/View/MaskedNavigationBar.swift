//
//  MaskedNavigationBar.swift
//  ForaBank
//
//  Created by Sergey on 14/01/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit

class MaskedNavigationBar: UIView {
    
    // MARK: - Properties
    let viewMask = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.mask = viewMask
        layer.insertSublayer(gradientLayer, at: 0)
//        backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        setTopEdgeRounded(rect)
    }
}

// MARK: - Private methods
private extension MaskedNavigationBar {
    
    func setTopEdgeRounded(_ rect: CGRect) {
        let y: CGFloat = 33
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: rect.height))
        bezierPath.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height), controlPoint: CGPoint(x: rect.width / 2, y: rect.height - y))
        bezierPath.addLine(to: CGPoint(x: rect.width, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
//        let context = UIGraphicsGetCurrentContext()
//        context!.setLineWidth(4.0)
//        UIColor.white.setFill()
//        bezierPath.fill()
        
        viewMask.path = bezierPath.cgPath
        gradientLayer.frame.size = rect.size
    }
}
