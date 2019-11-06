//
//  BottomRoundedEdge.swift
//  ForaBank
//
//  Created by Дмитрий on 06/11/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import UIKit

class BottomRoundedEdge: UIView {

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
private extension BottomRoundedEdge {
    
    func setTopEdgeRounded(_ rect: CGRect) {
        let y: CGFloat = 33
        let curveTo: CGFloat = 0
        
            let bezierPath = UIBezierPath()
          bezierPath.move(to: CGPoint(x: 0, y: y))
          bezierPath.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
          bezierPath.addLine(to: CGPoint(x: rect.width, y: rect.height - y))
          bezierPath.addQuadCurve(to: CGPoint(x: 0, y: rect.height - y), controlPoint: CGPoint(x: rect.width / 2, y: rect.height))
          bezierPath.addLine(to: CGPoint(x: 0, y: rect.height))
          let context = UIGraphicsGetCurrentContext()
          context!.setLineWidth(15.0)
          UIColor.white.setFill()
          bezierPath.fill()
        
        viewMask.path = bezierPath.cgPath
    }
}
