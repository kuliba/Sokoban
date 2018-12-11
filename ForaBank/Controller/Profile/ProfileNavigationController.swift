//
//  ProfileNavigationController.swift
//  ForaBank
//
//  Created by Sergey on 11/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ProfileNavigationController: UINavigationController {

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
//        print("navigationBarClass")

    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
//        print("rootViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
//        print("aDecoder")
        NetworkManager.shared().isSignedIn { [unowned self] (flag) in
            if flag {
                let rootVC:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                self.setViewControllers([rootVC], animated: false)
            }
            else {
                let rootVC:LoginOrSignupViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginOrSignupViewController") as! LoginOrSignupViewController
                self.setViewControllers([rootVC], animated: false)
            }
        }
    }
}
