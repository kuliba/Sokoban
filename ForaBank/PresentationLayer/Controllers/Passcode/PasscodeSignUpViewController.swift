//
//  PasscodeSignUpViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 30.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import TOPasscodeViewController
import ReSwift
import Hero

class PasscodeSignUpViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var contentView: UIView!

    // MARK: - Actions

    @IBAction func backButtonClicked(_ sender: Any) {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func skipButtonClicked(_ sender: Any) {

//        ;;;;;;
        performSegue(withIdentifier: "fromRegSmsToPermissions", sender: nil)
    }

    var passcodeVC = PasscodeWrapperViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeVC.willMove(toParent: self)
        self.view.addSubview(passcodeVC.view)
        self.addChild(passcodeVC)
        passcodeVC.didMove(toParent: self)

        passcodeVC.setupDelegate(delegate: self)
        
        store.subscribe(self) { state in
            state.select { $0.passcodeSignUpState }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let button = UIButton()
//        button.titleLabel?.text =

        passcodeVC.setTitleLabel(titleText: "Создайте код:")
//        passcodeVC.setRightButton(button: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
            passcodeVC.resetPasscode(animated: true, playImpact: true)
            return
        }
        if let firstPasscode = state.passcodeFirst, firstPasscode.count > 0, state.counter == 0 {
            passcodeVC.setTitleLabel(titleText: "Повторите код:")
            passcodeVC.resetPasscode(animated: false, playImpact: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let passcodeWrapperVC = destination as? PasscodeWrapperViewController {
            passcodeVC = passcodeWrapperVC
            passcodeWrapperVC.setupDelegate(delegate: self)
        }
    }
}

// MARK: - TOPasscodeViewControllerDelegate

extension PasscodeSignUpViewController: TOPasscodeViewControllerDelegate {

    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        store.dispatch(enterCode(code: code))
        return true
    }

    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {

    }

    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        store.dispatch(clearSignUpProcess)
        dismiss(animated: true, completion: nil)
    }
}
