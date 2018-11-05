//
//  SignInViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 05/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    // MARK: - Actions
    @IBAction func backButtonClicked() {
        dismiss(animated: true)
    }
    
    @IBAction func signInButtonClicked() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
