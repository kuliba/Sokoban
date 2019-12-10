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

    typealias SignInState = (passcodeState: PasscodeSignInState, verificationState: VerificationCodeState)

    let passcodeVC = PasscodeViewController(rightTitle: NSLocalizedString("Logout", comment: "Logout"), style: .opaqueLight, passcodeType: .fourDigits)

    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeVC.passcodeView.titleLabel.adjustsFontSizeToFitWidth = true
        passcodeVC.passcodeView.titleLabel.text = "Введите код:"
        passcodeVC.rightAccessoryButton?.titleLabel?.text = "Выход"

        passcodeVC.delegate = self
        passcodeVC.automaticallyPromptForBiometricValidation = true
        passcodeVC.allowBiometricValidation = true

        if BioMetricAuthenticator.shared.touchIDAvailable() && SettingsStorage.shared.allowedBiometricSignIn() {
            passcodeVC.biometryType = .touchID
        } else if BioMetricAuthenticator.shared.faceIDAvailable() && SettingsStorage.shared.allowedBiometricSignIn() {
            passcodeVC.biometryType = .faceID
        } else {
            passcodeVC.leftAccessoryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
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
            return $0.select { SignInState(passcodeState: $0.passcodeSignInState, verificationState: $0.verificationCodeState) }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func newState(state: SignInState) {
        guard state.passcodeState.isShown == true else {
            dismiss(animated: true, completion: nil)
            return
        }
        if state.passcodeState.failCounter >= 1 {
            passcodeVC.passcodeView.titleLabel.text = "Осталось \(3 - state.passcodeState.failCounter) попыток"
            passcodeVC.passcodeView.resetPasscode(animated: true, playImpact: false)
        }

        if state.verificationState.isShown == true {
            let paymentStoryboard = UIStoryboard(name: "Registration", bundle: nil)
            let verifyVC = paymentStoryboard.instantiateViewController(withIdentifier: "smsVerification")
            verifyVC.modalTransitionStyle = .crossDissolve

            present(verifyVC, animated: true, completion: nil)
        }
    }
}

//MARK: - TOPasscodeViewControllerDelegate

extension PasscodeSignInViewController: TOPasscodeViewControllerDelegate {

    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        store.dispatch(startSignInWith(passcode: code))
        return true
    }

    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {

    }

    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        PasscodeService.shared.cancelPasscodeAuth()
    }

    func didPerformBiometricValidationRequest(in passcodeViewController: TOPasscodeViewController) {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Вход в приложение") { (result) in
            switch result {
            case .success(_):
                store.dispatch(startSignInWithBiometric)
            case .failure(_):
                print("Authentication Failed")
            }
        }
    }
}
