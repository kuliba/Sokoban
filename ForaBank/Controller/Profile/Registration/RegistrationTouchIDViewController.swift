//
//  RegistrationTouchIDViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 02/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class RegistrationTouchIDViewController: UIViewController {

    
    var segueId: String? = nil
    
    @IBAction func backButtonClicked(_ sender: Any) {
//        dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
