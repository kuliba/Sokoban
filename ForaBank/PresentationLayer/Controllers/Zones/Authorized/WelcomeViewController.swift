//
//  WelcomeViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Hero
import ReSwift

class WelcomeViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    var timer: Timer?
    let transitionDuration: TimeInterval = 2
    var isProductsLoaded = false

    var segueId: String? = nil
    var animator: UIViewPropertyAnimator? = nil

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        store.dispatch(invalidateCurrentProducts)
        
        timer = Timer.scheduledTimer(timeInterval: transitionDuration, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: false)
        
        greetingLabel.text = getGreeting() + ","
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

        store.subscribe(self) { state in
            state.select { $0 }
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
        store.unsubscribe(self)
    }

    func newState(state: State) {
        let userState = state.userState
        let productsState = state.productsState

        if let firstName = userState.profile?.firstName, let patronymic = userState.profile?.patronymic, firstName != "", patronymic != "" {
            nameLabel.text = "\(firstName) \(patronymic)!"
        }

        if let isUpToDatePoducts = productsState.isUpToDateProducts {
            isProductsLoaded = isUpToDatePoducts
            continueIfNeeded()
        }
    }
}

private extension WelcomeViewController {
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 0..<4:
            return "Здравствуйте"
        case 4..<12:
            return "Доброе утро"
        case 12..<18:
            return "Добрый день"
        case 18..<24:
            return "Добрый вечер"
        default:
            break
        }
        return "Здравствуйте"
    }

    @objc private func timerFired() {
        guard let timer = timer else {
            return
        }

        timer.invalidate()
        continueIfNeeded()
    }

    private func continueIfNeeded() {
        guard let timer = timer else {
            return
        }

        if !timer.isValid && isProductsLoaded {
            navigationController?.popToRootViewController(animated: true)
            performSegue(withIdentifier: "formWelcomeToTabBarSegue", sender: nil)
        }
    }
}
