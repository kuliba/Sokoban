//
//  WelcomeViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Hero

class WelcomeViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!

    let transitionDuration: TimeInterval = 2

    var segueId: String? = nil
    var animator: UIViewPropertyAnimator? = nil

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignIn" || segueId == "Registration" || segueId == nil {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "logout" {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        backgroundImageView.alpha = 0
        self.backgroundImageView.transform = CGAffineTransform(translationX: 20, y: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NetworkManager.shared().getProducts { (success, products) in
            print(products)
        }
        containerView.hero.modifiers = nil
        UIView.animate(withDuration: 2, delay: 0, options: .beginFromCurrentState, animations: {
            self.backgroundImageView.transform = CGAffineTransform.identity
            self.backgroundImageView.alpha = 0.1
        }, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "SignIn" || segueId == "Registration" || segueId == nil {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
    }

}
