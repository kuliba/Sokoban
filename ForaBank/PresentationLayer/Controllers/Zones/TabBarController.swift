/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero
import ReSwift
import TOPasscodeViewController

class TabBarController: UITabBarController, StoreSubscriber {

    @IBAction func unwindSegue(segue: UIStoryboardSegue) { }

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
            
        }
    }

    // MARK: - public methods
    func setNumberOfTabsAvailable() {
        // if !signedIn (!authorized)
        NetworkManager.shared().isSignedIn { [unowned self] (flag) in
            if !flag && self.viewControllers?.count == 5 {
                self.viewControllers?.remove(at: 1)
                self.viewControllers?.remove(at: 1)
            }
            else if self.viewControllers?.count == 3 {
                let depositsStoryboard: UIStoryboard = UIStoryboard(name: "Deposits", bundle: nil)
                let depositsRootVC = depositsStoryboard.instantiateViewController(withIdentifier: "depositsRoot") as! CarouselViewController
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
