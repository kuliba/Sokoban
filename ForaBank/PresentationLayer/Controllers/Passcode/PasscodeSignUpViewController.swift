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

    var passcodeVC: PasscodeWrapperViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradientLayerView()
        view.clipsToBounds = true
        if let head = header as? MaskedNavigationBar {
            head.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            head.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            head.gradientLayer.colors = [UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }

        store.subscribe(self) { state in
            state.select { $0.passcodeSignUpState }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        passcodeVC?.setTitleLabel(titleText: "Создайте код:")
        passcodeVC?.setRightButton(button: nil)

        if let nav = navigationController as? ProfileNavigationController {
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                nav.pageControl.setCurrentPage(at: 2)
            }, completion: nil)
        }
        if isMovingToParent {
            containerView.hero.id = "content"
            view.hero.id = "view"
            contentView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: contentView.frame.origin.x + view.frame.width, y: 0))
            ]
        } else {
            header.hero.id = "head"
            containerView.hero.id = "content"
            view.hero.id = "view"
            contentView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: contentView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        store.subscribe(self) { state in
            state.select { $0.passcodeSignUpState }
        }

        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        contentView.hero.modifiers = nil
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)

        if isMovingFromParent {
            containerView.hero.id = "content"
            view.hero.id = "view"
            header.hero.id = "head"
            contentView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: contentView.frame.origin.x + view.frame.width, y: 0)),
            ]
        } else {
            containerView.hero.id = "content"
            view.hero.id = "view"
            contentView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: contentView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        contentView?.hero.modifiers = nil
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }

    func newState(state: PasscodeSignUpState) {
        guard state.isFinished != true else {
            skipButtonClicked(self)
            return
        }
        guard state.counter < 1 else {
            passcodeVC?.resetPasscode(animated: true, playImpact: true)
            return
        }
        if let firstPasscode = state.passcodeFirst, firstPasscode.count > 0, state.counter == 0 {
            passcodeVC?.setTitleLabel(titleText: "Повторите код:")
            passcodeVC?.resetPasscode(animated: false, playImpact: false)
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

// MARK: - Private methods

extension PasscodeSignUpViewController {

    func addGradientLayerView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        if header is MaskedNavigationBar {
            gradientLayer.colors = [UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor]
        } else {
            gradientLayer.colors = [UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }
    }
}

extension PasscodeSignUpViewController: TOPasscodeViewControllerDelegate {

    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        store.dispatch(enterCode(code: code))
        return true
    }

    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {

    }
}
