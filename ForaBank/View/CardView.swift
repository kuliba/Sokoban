//
//  CardView.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 19/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CardView: UIView {
    // MARK: - Properties
    @IBInspectable var color1: UIColor = .clear
    @IBInspectable var color2: UIColor = .clear
    let gradientLayer = CAGradientLayer()
    let gradientView = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        clipsToBounds = true
        
        gradientView.layer.addSublayer(gradientLayer)
        gradientLayer.cornerRadius = 10
        gradientLayer.masksToBounds = true
        insertSubview(gradientView, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)//gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            color1.cgColor,
            color2.cgColor
        ]
    }
}
