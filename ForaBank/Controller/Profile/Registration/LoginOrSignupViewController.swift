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
        print("viewDidLayoutSubviews")
        setButtonsAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        backgroundImageView.isHidden = false
        if segueId == "SignIn" || segueId == "Registration" {
//            backgroundImageView.hero.modifiers = [
//                HeroModifier.duration(0.6),
//                HeroModifier.delay(0.2),
//                HeroModifier.translate(CGPoint(x: 20, y: 0)),
//                HeroModifier.opacity(0)
//            ]
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "logout" {
//            backgroundImageView.hero.modifiers = [
//                HeroModifier.duration(0.6),
//                HeroModifier.delay(0.2),
//                HeroModifier.translate(CGPoint(x: 20, y: 0)),
//                HeroModifier.opacity(0)
//            ]
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        backgroundImageView.bounds.origin.x = 0
        backgroundImageView.alpha = 0
        self.backgroundImageView.transform = CGAffineTransform(translationX: 20, y: 0)
        animator = UIViewPropertyAnimator(duration: 2, curve: .linear, animations: {
//            self.backgroundImageView.bounds.origin.x = -20
            self.backgroundImageView.transform = CGAffineTransform.identity
            self.backgroundImageView.alpha = 0.1
//            self.view.layoutIfNeeded()
        })
//        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2, delay: 0, options: .beginFromCurrentState, animations: {
//            self.backgroundImageView.transform = CGAffineTransform.identity
//            self.backgroundImageView.alpha = 0.1
//        }, completion: { (pos) in
//            self.backgroundImageView.transform = CGAffineTransform.identity
//            print("kek")
//        })
//        animator?.addCompletion({ (pos) in
//            print("kek")
//        })
        animator?.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.hero.modifiers = nil
        containerView.hero.modifiers = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        animator?.pauseAnimation()
        let position = backgroundImageView.layer.position
        let alpha = backgroundImageView.alpha
        backgroundImageView.center = position
        backgroundImageView.alpha = alpha
        animator?.pauseAnimation()
        animator?.stopAnimation(true)
//        backgroundImageView.isHidden = true
        if segueId == "SignIn" || segueId == "Registration" {
//            backgroundImageView.hero.modifiers = [
//                HeroModifier.duration(0.5),
//                HeroModifier.translate(CGPoint(x: 20, y: 0)),
//                HeroModifier.opacity(0)
//            ]
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
//                HeroModifier.delay(0.3),
                HeroModifier.opacity(0)
            ]
//            backgroundImageView.hero.modifiers = [
//                HeroModifier.duration(0.5),
//                HeroModifier.opacity(0),
//                HeroModifier.be
//            ]
        }
        
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
            self.backgroundImageView.transform = CGAffineTransform.identity
            self.backgroundImageView.alpha = 0
        })
//        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
//            self.backgroundImageView.transform = CGAffineTransform.identity
//            self.backgroundImageView.alpha = 0
//        }, completion: { (pos) in
//            print("lil")
//        })
//        animator?.addCompletion({ (pos) in
//            print("lil")
//        })
        animator?.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        backgroundImageView.alpha = 0
        backgroundImageView.hero.modifiers = nil
        containerView.hero.modifiers = nil
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
    }
    
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
