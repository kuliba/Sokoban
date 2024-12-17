//
//  NavigationBarUIView.swift
//  ForaBank
//
//  Created by Дмитрий on 18.08.2021.
//

import UIKit

class NavigationBarUIView: UIView {

    var trailingLeftAction: (() -> Void)?
    var trailingRightAction: (() -> Void)?
    
    @IBOutlet weak var trailingLeftButton: UIButton!
    @IBOutlet weak var trailingRightButton: UIButton!
    
    @IBOutlet weak var textField: MaskedTextField!
    @IBOutlet weak var searchIcon: UIImageView!
    
    @IBOutlet weak var searchIconWidth: NSLayoutConstraint!
    @IBOutlet weak var searchIconHeight: NSLayoutConstraint!
    
    @IBOutlet weak var foraAvatarImageView: UIImageView!
    
    @IBAction func trailingLeftButtonTapped(_ sender: Any) {
        trailingLeftAction?()
    }
    
    @IBAction func trailingRightButtonTapped(_ sender: Any) {
        trailingRightAction?()
    }
    
}
