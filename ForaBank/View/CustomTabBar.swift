//
//  CustomTabBar.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBar {

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setTabBarWhite()
    }
}

// MARK: - Private methods
private extension CustomTabBar {
    
    func setTabBarWhite() {
        backgroundImage = UIImage()
        shadowImage = UIImage()
    }
}
