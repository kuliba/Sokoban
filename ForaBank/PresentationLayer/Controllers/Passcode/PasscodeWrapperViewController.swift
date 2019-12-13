//
//  PasscodeWrapperViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 31.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import TOPasscodeViewController

class PasscodeWrapperViewController: UIViewController {

    let passcodeVC = PasscodeViewController(rightTitle: NSLocalizedString("Cancel", comment: "Cancel"), style: .opaqueLight, passcodeType: .fourDigits)

    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeVC.passcodeView.titleLabel.adjustsFontSizeToFitWidth = true

        passcodeVC.willMove(toParent: self)
        self.view.addSubview(passcodeVC.view)
        self.addChild(passcodeVC)
        passcodeVC.didMove(toParent: self)
    }

    func setupDelegate(delegate: TOPasscodeViewControllerDelegate) {
        passcodeVC.delegate = delegate
    }

    func setTitleLabel(titleText: String) {
        passcodeVC.passcodeView.titleLabel.text = titleText
    }

    func setRightButton(button: UIButton?) {

        guard button != nil else {
            passcodeVC.removeCancelButton()
            return
        }
        passcodeVC.rightAccessoryButton = button
    }

    func resetPasscode(animated: Bool, playImpact: Bool) {
        passcodeVC.passcodeView.resetPasscode(animated: animated, playImpact: playImpact)
    }
}
