//
//  BaseViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 20.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Actions

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBOutlet weak var backButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackButton()
    }

    func setupBackButton() {
        if navigationController == nil || tabBarController == nil {
            backButton?.isHidden = true
        } else if isModal {
            backButton?.isHidden = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
