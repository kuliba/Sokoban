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

class SignInViewController: UIViewController{

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var contentView: RoundedEdgeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var buttonSignIn: ButtonRounded!
    @IBOutlet weak var foraPreloader: RefreshView!

    var segueId: String? = nil
    var backSegueId: String? = nil
    private let manager = UserManager()

    
      @IBAction func phoneNumberChanged(_ sender: UITextField) {
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
    //        return false
        }
    

    // MARK: - Actions
    @IBAction func backButtonClicked() {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
    }
    @IBAction func tappedButton(sender: UIButton!) {
    }

    @IBAction func signInButtonClicked() {
        //foraPreloader.frame = buttonSignIn.frame
        foraPreloader.startAnimation()
        foraPreloader.isHidden = false
        buttonSignIn.isHidden = true
        //buttonSignIn.changeEnabled(isEnabled: false)
        NetworkManager.shared().login(login: cleanNumber(number:self.loginTextField.text) ?? "",
                                      password: self.passwordTextField.text ?? "",
                                      completionHandler: { [unowned self] success, errorMessage in
                                          if success {
                                            let user = ObjectUser()
                                            user.email = "\(String(describing: cleanNumber(number: self.loginTextField.text ?? "")))@forabank.ru"
                                               user.password = self.passwordTextField.text ?? ""
                                            self.manager.login(user: user) { response in
                                                 switch response {
                                                 case .failure: print("Fail")
                                                 case .success: print("Success")
                                                 }
                                               }
                                            self.foraPreloader.stopAnimating()
                                            self.foraPreloader.isHidden = true
                                            self.buttonSignIn.isHidden = false
                                            //self.buttonSignIn.changeEnabled(isEnabled: true)
                                           
                                                self.performSegue(withIdentifier: "smsVerification", sender: self)
                                                store.dispatch(createCredentials(login: self.loginTextField.text ?? "", pwd: self.passwordTextField.text ?? ""))

                                          } else {
                                              AlertService.shared.show(title: "Ошибка", message: errorMessage ?? "Повторите позднее", cancelButtonTitle: "Ок", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
                                            self.buttonSignIn.isHidden = false
                                            self.foraPreloader.stopAnimating()
                                            self.foraPreloader.isHidden = true
                                          }
                                      })

    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        loginTextField.text = "79626129268"
//        passwordTextField.text = "34011alleNm!"
        _ = loginTextField.becomeFirstResponder()
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
            vc.login = loginTextField.text
            vc.password = passwordTextField.text
        }
    }
}


extension SignInViewController{
    private func saveLoginAndPassword(_ login: String, _ password:String){
        
    }
}


extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
