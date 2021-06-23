//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
import SwiftEntryKit

struct CastomPopUpView< T: UIView > {
    
    
    let view = UIView()
    
    func setupAttributs () -> EKAttributes {
        
        let h = T().layer.bounds.height
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)))
        
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7, anchorPosition: .automatic, spring: .init(damping: 1, initialVelocity: 0)),
                         scale: .init(from: 0.2, to: 1, duration: 0.7),
                         fade: .init(from: 0.2, to: 1, duration: 0.3))
        
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        return attributes
    }
    
    
    func showAlert () {

        SwiftEntryKit.display(entry: T(), using: setupAttributs())

    }
    
    func exit() {
       
        SwiftEntryKit.dismiss()
    
    }
}
