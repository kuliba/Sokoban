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
    
   static func setupAttributs () -> EKAttributes {
        
        let view = UIView()
 //       let h = T().layer.bounds.height
        view.backgroundColor = .green
        view.layer.frame.size = CGSize(width: 200, height: 400)
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)))
        attributes.windowLevel = .normal
        attributes.position = .bottom
        
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.constant(value: view.layer.bounds.height)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        return attributes
    }
    
    
    func showAlert () {

        SwiftEntryKit.display(entry: view, using: CastomPopUpView.setupAttributs())

    }
    
    func exit() {
       
        SwiftEntryKit.dismiss()
    
    }
}
