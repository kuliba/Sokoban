//
//  PasscodeViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import TOPasscodeViewController
import ReSwift
import BiometricAuthentication

class PasscodeSignInViewController: UIViewController, StoreSubscriber {

    let passcodeVC = TOPasscodeViewController(style: .opaqueLight, passcodeType: .sixDigits)

    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeVC.delegate = self
        passcodeVC.automaticallyPromptForBiometricValidation = true
        passcodeVC.allowBiometricValidation = true
        if BioMetricAuthenticator.shared.touchIDAvailable() {
            passcodeVC.biometryType = .touchID
        } else if BioMetricAuthenticator.shared.faceIDAvailable() {
            passcodeVC.biometryType = .faceID
        } else {
            passcodeVC.allowBiometricValidation = false
        }

        passcodeVC.willMove(toParent: self)
        self.view.addSubview(passcodeVC.view)
        self.addChild(passcodeVC)
        passcodeVC.didMove(toParent: self)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.modalPresentationStyle = .overCurrentContext
        store.subscribe(self) {
            return $0.select { $0.passcodeSignInState }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func newState(state: PasscodeSignInState) {
        guard state.isShown == true else {
            dismiss(animated: true, completion: nil)
            return
        }
        if state.failCounter >= 1 {
            passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: false)
        }
    }
}

extension PasscodeSignInViewController: TOPasscodeViewControllerDelegate {

    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        store.dispatch(signInWith(passcode: code))
        return true
    }

    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {

    }

    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        //store.dispatch(setPasscode)
    }

    func didPerformBiometricValidationRequest(in passcodeViewController: TOPasscodeViewController) {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Вход в приложение") { (result) in
            switch result {
            case .success(_):
                store.dispatch(signInWithBiometric)
            case .failure(let error):
                print("Authentication Failed")
            }
        }
    }
}
