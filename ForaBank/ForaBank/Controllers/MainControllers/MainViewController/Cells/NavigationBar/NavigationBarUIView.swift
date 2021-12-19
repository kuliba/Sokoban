//
//  NavigationBarUIView.swift
//  ForaBank
//
//  Created by Дмитрий on 18.08.2021.
//

import UIKit

class NavigationBarUIView: UIView {

    var bellTapped: (() -> Void)?
    
    @IBOutlet weak var secondButton: UIImageView!
    @IBOutlet weak var bellIcon: UIButton!
    @IBOutlet weak var textField: MaskedTextField!
    @IBOutlet weak var searchIcon: UIImageView!
    
    
    @IBAction func bellButtonTapped(_ sender: Any) {
        bellTapped?()
    }

    
}
