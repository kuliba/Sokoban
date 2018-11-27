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
        //setSelectedIndexToLast()
        selectedIndex = 0
    }
    
    @IBAction func unwindSegue(segue:UIStoryboardSegue) { }
}

// MARK: - Private methods
private extension TabBarController {

    func setSelectedIndexToLast() {
        guard let tabs = tabBar.items else { return }
        selectedIndex = tabs.endIndex - 1
    }
    
    func setNumberOfTabsAvailable() {
        // if !signedIn (!authorized)
        viewControllers?.remove(at: 1)
    }
}

extension TabBarController: CustomTransitionOriginator, CustomTransitionDestination {
    var fromAnimatedSubviews: [String : UIView] {
        var views = [String : UIView]()
        guard let c = selectedViewController as? CustomTransitionOriginator else {
            return views
        }
        views.merge(c.fromAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
        return views
    }
    
    var toAnimatedSubviews: [String : UIView] {
        var views = [String : UIView]()
        guard let c = selectedViewController as? CustomTransitionDestination else {
            return views
        }
        views.merge(c.toAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
        return views
    }
}
