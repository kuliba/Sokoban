//
//  SignInViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 05/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    // MARK: - Actions
    @IBAction func backButtonClicked() {
//        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInButtonClicked() {
//        presentingViewController?.presentingViewController?.dismiss(animated: true)
//        navigationController?.popViewController(animated: true)
        NetworkManager.shared().csrf { [unowned self] (success) in
            print("!!signInButtonClicked completion")
            if success {
                NetworkManager.shared().loginDo(login: self.loginTextField.text ?? "",
                                                password: self.passwordTextField.text ?? "",
                                                completionHandler: { (success) in
                                                    if success {
                                                        self.performSegue(withIdentifier: "smsVerification", sender: self)
                                                    }
                })
            }
        }
        
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
