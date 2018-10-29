//
//  CardView.swift
//  ForaBank
//
//  Created by IM on 19/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CardView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
    }

}
