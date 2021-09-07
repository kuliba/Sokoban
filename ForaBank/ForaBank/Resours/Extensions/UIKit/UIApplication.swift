//
//  UIApplication.swift
//  ForaBank
//
//  Created by Mikhail on 03.09.2021.
//

import UIKit

extension UIApplication {

    class func topViewController(baseViewController: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {

        if let navigationController = baseViewController as? UINavigationController {
            return topViewController(baseViewController: navigationController.visibleViewController)
        }

        if let tabBarViewController = baseViewController as? UITabBarController {

            let moreNavigationController = tabBarViewController.moreNavigationController

            if let topViewController = moreNavigationController.topViewController, topViewController.view.window != nil {
                return topViewController
            } else if let selectedViewController = tabBarViewController.selectedViewController {
                return topViewController(baseViewController: selectedViewController)
            }
        }

        if let splitViewController = baseViewController as? UISplitViewController, splitViewController.viewControllers.count == 1 {
            return topViewController(baseViewController: splitViewController.viewControllers[0])
        }

        if let presentedViewController = baseViewController?.presentedViewController {
            return topViewController(baseViewController: presentedViewController)
        }

        return baseViewController
    }
}
