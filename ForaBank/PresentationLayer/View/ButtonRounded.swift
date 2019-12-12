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
    
    func changeEnabled(isEnabled: Bool) {
        self.isEnabled = isEnabled
        alpha = isEnabled ? 1 : 0.5
    }
}

class ButtonBlackRounded: UIButton {
    let gold = UIColor(named: "#000000")
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height / 2
    }
    
    func changeEnabled(isEnabled: Bool) {
        self.isEnabled = isEnabled
        alpha = isEnabled ? 1 : 0.5
    }
}





