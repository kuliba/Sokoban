//
//  GradientView2.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 02/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class GradientView2: UIView {
    
    var color1: UIColor = .white
    var color2: UIColor = .black
    
    func addGradientView() {
        let gradientFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let gradientView = UIView(frame: gradientFrame)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            color1.cgColor,
            color2.cgColor
        ]
        gradientView.layer.addSublayer(gradientLayer)
        addSubview(gradientView)
    }
}
