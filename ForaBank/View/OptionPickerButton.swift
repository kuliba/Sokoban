//
//  PickerButton.swift
//  ForaBank
//
//  Created by Sergey on 15/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class OptionPickerButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.setImage(UIImage(named: "dropdown_button_icon"), for: .normal)
        self.backgroundColor = UIColor(hexFromString: "000000", alpha: 0.05)
        self.layer.cornerRadius = 3
        //print(self.imageEdgeInsets)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        //print(self.titleEdgeInsets)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
    }
    
}
