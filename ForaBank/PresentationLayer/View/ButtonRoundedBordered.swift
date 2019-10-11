//
//  ButtonRoundedBordered.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 02/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ButtonRoundedBordered: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 1
        layer.borderColor = titleColor(for: [])?.cgColor
        backgroundColor = .clear
    }
}
