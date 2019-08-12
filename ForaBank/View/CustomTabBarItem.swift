//
//  CustomTabBarItem.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CustomTabBarItem: UITabBarItem {

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setRenderingMode()
    }
}

// MARK: - Private methods
private extension CustomTabBarItem {
    
    func setRenderingMode() {
        selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        image = image?.withRenderingMode(.alwaysTemplate)
    }
}
