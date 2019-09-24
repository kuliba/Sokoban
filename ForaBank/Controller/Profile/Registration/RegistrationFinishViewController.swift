//
//  RegistrationFinishViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 02/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero

class RegistrationFinishViewController: UIViewController {

    var segueId: String? = nil

    @IBAction func completeButtonClicked(_ sender: Any) {
        store.dispatch(userDidSignIn)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "dismiss" {
            view.hero.modifiers = [
                HeroModifier.duration(0.3),
                HeroModifier.opacity(0)
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.hero.modifiers = nil
        view.hero.id = nil
    }

}
