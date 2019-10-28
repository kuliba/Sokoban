//
//  PasscodeSignUpViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import TOPasscodeViewController
import ReSwift

class PasscodeSignUpViewController: UIViewController, StoreSubscriber {

    let passcodeVC = TOPasscodeViewController(style: .opaqueLight, passcodeType: .fourDigits)

    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeVC.passcodeView.titleLabel.adjustsFontSizeToFitWidth = true
        passcodeVC.passcodeView.titleLabel.text = "Создайте код:"
        passcodeVC.delegate = self

        passcodeVC.willMove(toParent: self)
        self.view.addSubview(passcodeVC.view)
        self.addChild(passcodeVC)
        passcodeVC.didMove(toParent: self)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.modalPresentationStyle = .overCurrentContext

        store.subscribe(self) { state in
            state.select { $0.passcodeSignUpState }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }


    func newState(state: PasscodeSignUpState) {
        guard state.isFinished != true else {
            dismiss(animated: true, completion: nil)
            return
        }
        guard state.counter < 1 else {
            passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: false)
            return
        }
        if let firstPasscode = state.passcodeFirst, firstPasscode.count > 0, state.counter == 0 {
            passcodeVC.passcodeView.titleLabel.text = "Повторите код:"
            passcodeVC.passcodeView.resetPasscode(animated: false, playImpact: false)
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

extension PasscodeSignUpViewController: TOPasscodeViewControllerDelegate {

    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        store.dispatch(enterCode(code: code))
        return true
    }

    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {

    }

    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        //store.dispatch(setPasscode)
        dismiss(animated: true, completion: nil)
    }
}
