//
//  UISwitch.swift
//  ForaBank
//
//  Created by Mikhail on 23.06.2021.
//

import UIKit

extension UISwitch {
    
    func increaseThumb(){
        if let thumb = self.subviews[0].subviews[1].subviews[2] as? UIImageView {
            thumb.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }
}
