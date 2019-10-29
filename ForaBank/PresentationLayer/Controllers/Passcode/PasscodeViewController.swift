//
//  PasscodeViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 29.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import TOPasscodeViewController

class PasscodeViewController: TOPasscodeViewController {
    override func keypadButtonTapped() {
        guard let count = self.passcodeView.passcode?.count else { return }
        let title = count > 0 ? "Delete" : "Cancel"

        UIView.performWithoutAnimation {
            self.cancelButton.setTitle(NSLocalizedString(title, comment: title), for: .normal)
            self.cancelButton.sizeToFit()
        }
    }
}
