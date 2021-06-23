//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
import SwiftEntryKit

struct CastomPopUpView {
    
    
    let view = UIView()
    
   func setupAttributs () -> EKAttributes {
        
        let view = UIView()
 //       let h = T().layer.bounds.height
        view.backgroundColor = .green
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)))
        attributes.windowLevel = .normal
        attributes.position = .bottom
        
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .dismiss
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.1)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.intrinsic
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
         attributes.entranceAnimation = .init(
                     translate: .init(duration: 0.7, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)),
                     scale: .init(from: 0.6, to: 1, duration: 0.7),
                     fade: .init(from: 0.8, to: 1, duration: 0.3))
        return attributes
    }
    
    
    func showAlert () {

        SwiftEntryKit.display(entry: view, using: setupAttributs())

    }
    
    func exit() {
       
        SwiftEntryKit.dismiss()
    
    }
}
