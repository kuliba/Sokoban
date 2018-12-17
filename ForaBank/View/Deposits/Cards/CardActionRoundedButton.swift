//
//  CardActionRoundedButton.swift
//  ForaBank
//
//  Created by Sergey on 14/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CardActionRoundedButton: UIButton {
    
//    var highlightedBackgroundColor: UIColor?
//    var normalBackgroundColor: UIColor? {
//        didSet {
//            backgroundColor = normalBackgroundColor
//        }
//    }
//    var highlightedTintColor: UIColor?
//    var normalTintColor: UIColor? {
//        didSet {
//            tintColor = normalTintColor
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //print("CardActionRoundedButton init(frame: CGRect)")
        self.layer.cornerRadius = 22.5
        self.backgroundColor = .clear
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(hexFromString: "D3D3D3").cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//
//    override open var isHighlighted: Bool {
//        didSet {
//            if isHighlighted {
//                if highlightedBackgroundColor != nil {
//                    backgroundColor = highlightedBackgroundColor
//                }
//                if highlightedTintColor != nil {
//                 tintColor = highlightedTintColor
//                }
//            } else {
//                if
//            }
//
//        }
//    }
}
