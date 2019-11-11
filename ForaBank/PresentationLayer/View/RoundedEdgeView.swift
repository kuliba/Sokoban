//
//  RoundedEdgeView.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 26/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class RoundedEdgeView: UIView {
    
    // MARK: - Properties
    let viewMask = CAShapeLayer()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.mask = viewMask
    }
    
    override func draw(_ rect: CGRect) {
       setTopEdgeRounded(rect)
    }
}

// MARK: - Private methods
private extension RoundedEdgeView {
    
    func setTopEdgeRounded(_ rect: CGRect) {
        let y: CGFloat = 33
        let curveTo: CGFloat = 0
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: y))
        bezierPath.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        bezierPath.addLine(to: CGPoint(x: rect.width , y: rect.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: rect.height))
        bezierPath.close()
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(4.0)
        UIColor.white.setFill()
        bezierPath.fill()
        
        viewMask.path = bezierPath.cgPath
    }
}
