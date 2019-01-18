//
//  ProfileNavigationController.swift
//  ForaBank
//
//  Created by Sergey on 11/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero
import FlexiblePageControl
import DeviceKit

class ProfileNavigationController: UINavigationController {
    
    let pageControl = FlexiblePageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProfileNavigationController viewDidLoad")
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
        
        pageControl.isHidden = true
//        pageControl.alpha = 0
        pageControl.numberOfPages = 4
        pageControl.pageIndicatorTintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 234/255, green: 68/255, blue: 66/255, alpha: 1)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )
//        pageControl.backgroundColor = .black
        pageControl.setConfig(config)
        pageControl.animateDuration = 0
        pageControl.setCurrentPage(at: 0)
        view.addSubview(pageControl)
        var topInset: CGFloat = 0
        if Device().isOneOf(Constants.iphone5Devices) {
            topInset = 77
        } else if Device().isOneOf(Constants.xDevices) {
            topInset = 101
        } else {
            topInset = 101
        }
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-i-[p(10)]",
                                                           options: [],
                                                           metrics: ["i":topInset],
                                                           views: ["p":pageControl]))
        view.addConstraint(NSLayoutConstraint.init(item: pageControl,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .centerX,
                                                   multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: pageControl,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .notAnAttribute,
                                                   multiplier: 1, constant: 0))
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        self.view.bringSubviewToFront(pageControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Pro viewWillAppear")
        print(Hero.shared.isTransitioning)
        print(Hero.shared.isPresenting)
        if Hero.shared.isPresenting == false {
            print("cancel")
            Hero.shared.finish()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Pro viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Pro viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Pro viewDidDisappear")
    }
}
