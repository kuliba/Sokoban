//
//  UnauthorizedZoneTabBarController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 24/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Hero
import ReSwift
import TOPasscodeViewController

class UnauthorizedZoneTabBarController: UITabBarController, StoreSubscriber {

    @IBAction func unwindSegue(segue: UIStoryboardSegue) { }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        hero.isEnabled = true
        hero.tabBarAnimationType = .none
        delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        store.subscribe(self) { state in
            state.select { $0.passcodeSignInState }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    func newState(state: PasscodeSignInState) {
        if state.isShown == true {
            let passcodeVC = PasscodeSignInViewController()
            passcodeVC.modalPresentationStyle = .overFullScreen
            present(passcodeVC, animated: true, completion: nil)
        } else if state.isShown == false {
            NetworkManager.shared().isSignedIn { (isSignIn) in
                if isSignIn {
                    store.dispatch(userDidSignIn)
                }
            }
        }
    }
}

extension UnauthorizedZoneTabBarController: UITabBarControllerDelegate {
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


extension UnauthorizedZoneTabBarController: CustomTransitionOriginator, CustomTransitionDestination {
    var fromAnimatedSubviews: [String: UIView] {
        var views = [String: UIView]()
        guard let c = selectedViewController as? CustomTransitionOriginator else {
            return views
        }
        views.merge(c.fromAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
        return views
    }

    var toAnimatedSubviews: [String: UIView] {
        var views = [String: UIView]()
        guard let c = selectedViewController as? CustomTransitionDestination else {
            return views
        }
        views.merge(c.toAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
        return views
    }
}
