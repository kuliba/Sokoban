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

class ConfirmPassword: UIViewController {

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

    @IBOutlet weak var nonConfirmPassword: UILabel!
    
    // MARK: - Actions
    @IBAction func backButtonClicked() {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
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
                                               let alert = UIAlertController(title: "Неудача", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                                               alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                               self.present(alert, animated: true, completion: nil)
                                           }
                                       })
        if self.newPassword.text != self.newPasswordAgain.text && self.newPassword.text != "" {
                  let alert = UIAlertController(title: "Неудача", message: "Пароли не совпадают", preferredStyle: UIAlertController.Style.alert)
                  alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                  self.present(alert, animated: true, completion: nil)

                  return
              }
     }
    @IBAction func showPassword(_ sender: UIButton) {
         if newPassword.isSecureTextEntry == true {
             newPassword.isSecureTextEntry = false
             sender.isSelected = true
         } else {
             newPassword.isSecureTextEntry = true
             sender.isSelected = false
         }
     }
     @IBAction func showPassword2(_ sender: UIButton) {
         if newPasswordAgain.isSecureTextEntry == true {
             newPasswordAgain.isSecureTextEntry = false
             sender.isSelected = true
         } else {
             newPasswordAgain.isSecureTextEntry = true
             sender.isSelected = false
         }
     }
   
    // MARK: - Lifecycle
    @IBOutlet weak var buttonContinue: ButtonRounded!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonConfirmPassword.isHidden = true
//        buttonContinue.isEnabled = false
    }
    
    @IBAction func didChangePasswordAgain(_ sender: Any) {
//        if newPassword.text != newPasswordAgain.text{
//                  nonConfirmPassword.isHidden = false
//                  buttonContinue.isEnabled = false
//
//              } else if newPassword.text == newPasswordAgain.text{
//                  buttonContinue.isEnabled = true
//
//              }
        
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
