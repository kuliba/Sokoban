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

    let rightTitle: String

    init(rightTitle: String, style: TOPasscodeViewStyle, passcodeType: TOPasscodeType) {
        self.rightTitle = rightTitle
        super.init(style: style, passcodeType: passcodeType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keypadButtonTapped() {
        let count = self.passcodeView.passcode?.count ?? 0
        let title = (count > 0) && (count != nil) ? "Delete" : rightTitle

        UIView.performWithoutAnimation {
            self.cancelButton.setTitle(NSLocalizedString(title, comment: title), for: .normal)
            self.cancelButton.sizeToFit()
        }
    }

    func removeCancelButton() {
        cancelButton.setTitle("", for: .normal)
    }

    override func setUpAccessoryButtons() {
        super.setUpAccessoryButtons()
        if (self.cancelButton != nil) {
            UIView.performWithoutAnimation {
                self.cancelButton.setTitle(NSLocalizedString(rightTitle, comment: rightTitle), for: .normal)
                self.cancelButton.sizeToFit()
            }
        }
    }
}
