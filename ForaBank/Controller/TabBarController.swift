//
//  TabBarController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelectedIndexToLast()
    }
}

// MARK: - Private methods
private extension TabBarController {

    func setSelectedIndexToLast() {
        guard let tabs = tabBar.items else {
            return
        }
        selectedIndex = tabs.endIndex - 1
    }
    
    func setNumberOfTabsAvailable() {
        // if !signedIn (!authorized)
        viewControllers?.remove(at: 1)
    }
}
