//
//  FirstViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 14/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero

class LoginOrSignupViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var segueId: String? = nil
    var animator: UIViewPropertyAnimator? = nil
    
    let transitionDuration: TimeInterval = 2
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("viewDidLayoutSubviews")
        setButtonsAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Start viewWillAppear")
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
//        print(animator)
        backgroundImageView.alpha = 0
        self.backgroundImageView.transform = CGAffineTransform(translationX: 20, y: 0)
//        animator = UIViewPropertyAnimator(duration: 2, curve: .linear, animations: {
//            print("block")
//            print(self.backgroundImageView.transform)
//            print(self.backgroundImageView.bounds)
//            print(self.backgroundImageView.frame)
//            print(self.backgroundImageView.alpha)
//            self.backgroundImageView.transform = CGAffineTransform.identity
//            self.backgroundImageView.alpha = 0.1
////            self.view.layoutIfNeeded()
//        })
//        animator?.startAnimation()
//        print(animator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
//        backgroundImageView.alpha = 0
//        self.backgroundImageView.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 2, delay: 0, options: .beginFromCurrentState, animations: {
            self.backgroundImageView.transform = CGAffineTransform.identity
            self.backgroundImageView.alpha = 0.1
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        animator?.pauseAnimation()
//        let position = backgroundImageView.layer.position
//        let alpha = backgroundImageView.alpha
//        backgroundImageView.center = position
//        backgroundImageView.alpha = alpha
//
//        animator?.stopAnimation(true)
//        animator?.finishAnimation(at: UIViewAnimatingPosition.current)
        if segueId == "SignIn" || segueId == "Registration" || segueId == nil {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
        
//        animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
//            print("huek")
//            print(self.backgroundImageView.transform)
//            print(self.backgroundImageView.bounds)
//            print(self.backgroundImageView.frame)
//            print(self.backgroundImageView.alpha)
//            self.backgroundImageView.transform = CGAffineTransform.identity
//            self.backgroundImageView.alpha = 0
//        })
//        animator?.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        print("viewWillLayoutSubviews")
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueId = nil
        if let vc = segue.destination as? SignInViewController {
            segueId = "SignIn"
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
        if let vc = segue.destination as? RegistrationViewController {
            segueId = "Registration"
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
    }
    
    func setButtonsAppearance() {
        signInButton.backgroundColor = .clear
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        signInButton.layer.cornerRadius = signInButton.frame.height / 2
        
        registrationButton.layer.cornerRadius = registrationButton.frame.height / 2
    }
}
