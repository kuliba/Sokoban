/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero
import RMMapper

class PrepareResetPassword: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var contentView: RoundedEdgeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var centralView: UIView!
    
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordAgain: UITextField!
    var segueId: String? = nil
    var backSegueId: String? = nil

    
    // MARK: - Actions
    @IBAction func backButtonClicked() {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
   

    @IBAction func changeValue(_ sender: UITextField) {
        let updatedText = sender.text ?? ""
        let cleanPhoneNumber = updatedText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "+X (XXX) XXX-XXXX"
//        if string.count + range.location > mask.count {
//            return false
//        }

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask {
            if index == cleanPhoneNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else if ch == "+" || ch == "(" || ch == ")" || ch == "-" || ch == " " {
                result.append(ch)
            } else {
                //                    return false
            }
        }
        loginTextField.text = result
    }
    @IBAction func preparePasswordReset() {
         NetworkManager.shared().prepareResetPassword(login: self.loginTextField.text ?? "",
                                       completionHandler: { [unowned self] success, errorMessage in
                                           if success {
                                               self.performSegue(withIdentifier: "smsCheckCode", sender: self)
                                                                                } else {
                                               let alert = UIAlertController(title: "Неудача", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                                               alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                               self.present(alert, animated: true, completion: nil)
                                           }
                                       })
     }
    
    @IBAction func newPasswordReset() {
        NetworkManager.shared().newPasswordReset(password: self.newPassword.text ?? "",
                                       completionHandler: { [unowned self] success, errorMessage in
                                           if success {
                                               self.performSegue(withIdentifier: "finishResetPassword", sender: self)
                                                                                } else {
                                           let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                                               alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                           }
                                       })
     }

   
    // MARK: - Lifecycle
    @IBOutlet weak var buttonContinue: ButtonRounded!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignIn" {
            contentView.hero.id = "content"
            contentView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.beginWith([HeroModifier.opacity(1)]),
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "smsVerification" {
            contentView.hero.id = "content"
            view.hero.id = "view"
            view.hero.modifiers = [
                HeroModifier.duration(0.5)
            ]
            centralView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.forceAnimate,
                HeroModifier.delay(0),
                HeroModifier.zPosition(1),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.hero.modifiers = nil
        contentView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView.hero.modifiers = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "SignIn" {
            contentView.hero.id = "content"
            contentView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "smsVerification" {
            contentView.hero.id = "content"
            view.hero.id = "view"
            view.hero.modifiers = [
                HeroModifier.duration(0.5)
            ]
            centralView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0)),
                HeroModifier.forceNonFade
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.hero.modifiers = nil
        contentView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView.hero.modifiers = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
        segueId = nil
        if let vc = segue.destination as? RegistrationCodeVerificationViewController {
            segueId = segue.identifier
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
    }
}
