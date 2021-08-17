//
//  UISwitch.swift
//  ForaBank
//
//  Created by Mikhail on 23.06.2021.
//

import UIKit

extension UISwitch {
    
    func set(width: CGFloat, height: CGFloat) {

        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51

        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth

        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
    
    
    func increaseThumb(){
        if let thumb = self.subviews[0].subviews[1].subviews[2] as? UIImageView {
            thumb.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }
}
