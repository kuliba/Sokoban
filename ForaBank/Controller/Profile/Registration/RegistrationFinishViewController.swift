//
//  RegistrationFinishViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 02/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class RegistrationFinishViewController: UIViewController {

    @IBAction func completeButtonClicked(_ sender: Any) {
//        if let first = presentingViewController,
//            let second = first.presentingViewController,
//            let third = second.presentingViewController,
//            let fourth = third.presentingViewController,
//            let fifth = fourth.presentingViewController,
//            let sixth = fifth.presentingViewController {
//
//            fifth.view.isHidden = true
//            fourth.view.isHidden = true
//            third.view.isHidden = true
//            second.view.isHidden = true
//            first.view.isHidden = true
//
////            sixth.dismiss(animated: false)
//
//        }
//        self.navigationController?.popToRootViewController(animated: true)
        let rootVC:ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        if let t = self.tabBarController as? TabBarController {
            t.setNumberOfTabsAvailable()
        }
        self.navigationController?.setViewControllers([rootVC], animated: true)
    }
}
