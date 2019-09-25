//
//  App.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

func getRootVC() -> UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController
}

func setRootVC(newRootVC: UIViewController) {
    UIApplication.shared.keyWindow?.rootViewController = newRootVC
}

func topMostVC() -> UIViewController? {
    return UIApplication.getTopViewController()
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
