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
    
    let transitionDuration: TimeInterval = 2
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setButtonsAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignIn" {
            backgroundImageView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.5),
                HeroModifier.translate(CGPoint(x: 50, y: 0)),
                HeroModifier.opacity(0)
            ]
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "logout" {
            backgroundImageView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.5),
                HeroModifier.translate(CGPoint(x: 50, y: 0)),
                HeroModifier.opacity(0)
            ]
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.hero.modifiers = nil
        containerView.hero.modifiers = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "SignIn" {
            backgroundImageView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 50, y: 0)),
                HeroModifier.opacity(0)
            ]
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.3),
                HeroModifier.opacity(0)
            ]
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        backgroundImageView.hero.modifiers = nil
        containerView.hero.modifiers = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueId = nil
        if let vc = segue.destination as? SignInViewController {
            segueId = segue.identifier
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
