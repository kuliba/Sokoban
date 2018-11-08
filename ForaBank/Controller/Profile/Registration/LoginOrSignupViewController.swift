//
//  FirstViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 14/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

protocol LoginOrSignupViewControllerDelegate: class {
    func animateShowContainerView()
    func hideContainerView()
}

class LoginOrSignupViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setButtonsAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 250, animations: {
            self.backgroundImageView.alpha = 0.1
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 250, animations: {
            self.backgroundImageView.alpha = 0
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RegistrationViewController {
            vc.delegate = self
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

// MARK: - LoginOrSignupViewControllerDelegate
extension LoginOrSignupViewController: LoginOrSignupViewControllerDelegate {
    func hideContainerView() {
        containerView.alpha = 0
    }
    
    func animateShowContainerView() {
        UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
            self.containerView.alpha = 1
        })
    }
}
