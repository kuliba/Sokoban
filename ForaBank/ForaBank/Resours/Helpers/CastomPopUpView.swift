//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
import SwiftEntryKit

protocol CutomViewProtocol: UIView {
    
}

struct CastomPopUpView <T: CutomViewProtocol>  {
    
    let v = MainPopUpView<T>()
    
    func setupAttributs () -> EKAttributes {
        
        
        var attributes = EKAttributes.bottomNote
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)))
        attributes.windowLevel = .normal
        attributes.position = .bottom
        
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .dismiss
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 1)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.fill
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.safeArea = .overridden
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        attributes.statusBar = .dark
        return attributes
    }
    
    
    func showAlert () {
        
        SwiftEntryKit.display(entry: v , using: setupAttributs())
        
    }
    
    func exit() {
        
        SwiftEntryKit.dismiss()
        
    }
}


class MainPopUpView <T: UIView>: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        add()
        self.backgroundColor = .red
    }
    
    func add() {
        self.addSubview(T())
        heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class View_1: UIView, CutomViewProtocol {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
//        heightAnchor.constraint(equalToConstant: 300).isActive = true
//        widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.backgroundColor = .gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
