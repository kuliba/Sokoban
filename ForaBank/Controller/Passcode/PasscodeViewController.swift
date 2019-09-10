//
//  PasscodeViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import TOPasscodeViewController

class PasscodeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = UIColor.clear
//        view.isOpaque = false

        let passcodeVC = TOPasscodeViewController(style: .opaqueLight, passcodeType: .sixDigits)
        passcodeVC.delegate = self

        passcodeVC.willMove(toParent: self)
        self.view.addSubview(passcodeVC.view)
        self.addChild(passcodeVC)
        passcodeVC.didMove(toParent: self)
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

extension PasscodeViewController: TOPasscodeViewControllerDelegate {

    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        store.dispatch(setPasscode)
    }
}
