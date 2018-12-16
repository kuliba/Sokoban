//
//  ProfileNavigationController.swift
//  ForaBank
//
//  Created by Sergey on 11/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero

class ProfileNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        hero.navigationAnimationType = .none
        
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
