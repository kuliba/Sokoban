//
//  CircularImageView.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 26/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CircularImageView: UIImageView {
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setRounded()
    }
}

// MARK: - Private methods
private extension CircularImageView {
    
    func setRounded() {
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
    }
}
