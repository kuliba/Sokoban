//
//  GradientView.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 26/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    // MARK: - Properties
    @IBInspectable var color1: UIColor = .white
    @IBInspectable var color2: UIColor = .black
    let gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        setGradientView()
    }
}

// MARK: - Private methods
private extension GradientView {
    
    func setGradientView() {
        let gradientFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let gradientView = UIView(frame: gradientFrame)
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            color1.cgColor,
            color2.cgColor
        ]
        gradientView.layer.addSublayer(gradientLayer)
        insertSubview(gradientView, at: 0)
    }
}
