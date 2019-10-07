//
//  ButtonRounded.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 30/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ButtonRounded: UIButton {
    let gold = UIColor(named: "#ffe700ff")
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height / 2
            
    }
}




