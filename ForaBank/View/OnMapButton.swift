//
//  OnMapButton.swift
//  ForaBank
//
//  Created by Sergey on 15/01/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit

class OnMapButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithShadows()
    }
    
    func initWithShadows() {
        layer.cornerRadius = 5
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3.0)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 6
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(image, for: .highlighted)
    }
}
