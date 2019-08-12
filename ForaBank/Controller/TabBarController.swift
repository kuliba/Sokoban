//
//  TabBarController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero

class TabBarController: UITabBarController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setSelectedIndexToLast()
        setNumberOfTabsAvailable()
        selectedIndex = 0
        hero.isEnabled = true
        hero.tabBarAnimationType = .none
        delegate = self
    }
    
    @IBAction func unwindSegue(segue:UIStoryboardSegue) { }
    
    // MARK: - public methods
    func setNumberOfTabsAvailable() {
        // if !signedIn (!authorized)
        NetworkManager.shared().isSignedIn { [unowned self] (flag)  in
            if !flag && self.viewControllers?.count == 5 {
                self.viewControllers?.remove(at: 1)
                self.viewControllers?.remove(at: 1)
            }
            else if self.viewControllers?.count == 3 {
                let depositsStoryboard: UIStoryboard = UIStoryboard(name: "Deposits", bundle: nil)
                let depositsRootVC = depositsStoryboard.instantiateViewController(withIdentifier: "depositsRoot") as! DepositsViewController
                self.viewControllers?.insert(depositsRootVC, at: 1)
                let paymentStoryboard: UIStoryboard = UIStoryboard(name: "Payment", bundle: nil)
                let paymentRootVC = paymentStoryboard.instantiateViewController(withIdentifier: "paymentRoot") as! PaymentsViewController
                self.viewControllers?.insert(paymentRootVC, at: 2)
            }
        }
    }
}

// MARK: - Private methods
private extension TabBarController {
    
    func setSelectedIndexToLast() {
        guard let tabs = tabBar.items else { return }
        selectedIndex = tabs.endIndex - 1
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return Hero.shared.tabBarController(tabBarController, shouldSelect: viewController)
//        guard tabBarController.selectedViewController !== viewController else {
//            return false
//        }
//        if Hero.shared.isTransitioning {
//            Hero.shared.cancel(animate: false)
//        }
//        return true
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Hero.shared.tabBarController(tabBarController, animationControllerForTransitionFrom: fromVC, to: toVC)
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
