//
//  RegistrationLoginPasswordViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 31/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import FlexiblePageControl
import Hero
import StoreKit

enum PasswordStrength: Int {
    case None
    case Weak
    case Moderate
    case Strong
    static func checkStrength(password: String) -> PasswordStrength {
        let len: Int = password.count
        var strength: Int = 0
        switch len {
        case 0:
            return .None
        case 1...4:
            strength += 1
        case 5...8:
            strength += 2
        default:
            strength += 3
        }
        // Upper case, Lower case, Number & Symbols
        let patterns = ["^(?=.*[A-Z]).*$", "^(?=.*[a-z]).*$", "^(?=.*[0-9]).*$", "^(?=.*[!@#%&-_=:;\"'<>,`~\\*\\?\\+\\[\\]\\(\\)\\{\\}\\^\\$\\|\\\\\\.\\/]).*$"]

        for pattern in patterns {
            let set = CharacterSet(charactersIn: pattern)
            if let r = password.rangeOfCharacter(from: set, options: .regularExpression, range: Range(uncheckedBounds: (lower: password.startIndex, upper: password.endIndex))),
                r.isEmpty == false {
                strength += 1
            }
            //            if (password.rangeOfString(pattern, options: .RegularExpressionSearch) != nil) {
            //                strength++
            //            }
        }
        switch strength {
        case 0:
            return .None
        case 1...3:
            return .Weak
        case 4...6:
            return .Moderate
        default:
            return .Strong
        }
    }
}

class RegistrationLoginPasswordViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    @IBOutlet weak var centralView: UIScrollView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var agreementCheckbox: UIButton!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet weak var inputPasswordLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: ActivityIndicatorView!

    var headerSnapshot: UIView? = nil

    var cardNumber: String? = nil

   
    @IBAction func linkPrivacyPolicy(_ sender: Any) {
       UIApplication.shared.openURL(URL(string: "https://www.forabank.ru/private/dokumenty/UKBO_03-08-2019.pdf")!)
        
    }
    var segueId: String? = nil
    var backSegueId: String? = nil
//    let pageControl = FlexiblePageControl()
    let gradientView = UIView()
    let circleView = UIView()
   
    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        segueId = backSegueId
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func `continue`(_ sender: Any) {
        if self.phoneTextField.text == "" {
            let alert = UIAlertController(title: "Неудача", message: "Введите номер телефона", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        }
        guard let phone = self.phoneTextField.text?.removeWhitespace()
            .replace(string: "+", replacement: "")
            .replace(string: "(", replacement: "")
            .replace(string: ")", replacement: "")
            .replace(string: "-", replacement: "")else {
                return
        }

        if self.loginTextField.text == "" {
            let alert = UIAlertController(title: "Неудача", message: "Введите логин", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        }

        if self.passwordTextField.text != self.confirmPasswordTextField.text && self.passwordTextField.text != "" {
            let alert = UIAlertController(title: "Неудача", message: "Пароли не совпадают", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        }

        guard let cardNum = cardNumber, let login = self.loginTextField.text, let pwd = self.passwordTextField.text else {
            return
        }
        activityIndicatorView.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().checkClient(cardNumber: cardNum, login: login, password: pwd, phone: phone, verificationCode: 0, completionHandler: { [weak self] success, errorMessage in

            self?.continueButton.isHidden = false
            self?.activityIndicatorView.stopAnimating()
            if success {
                store.dispatch(createdLoginPwd(login: login, pwd: pwd))
                self?.performSegue(withIdentifier: "regSmsVerification", sender: nil)
            } else {
                let alert = UIAlertController(title: "Неудача", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }

    @IBAction func acceptAgreement(_ sender: Any) {
        if agreementCheckbox.isSelected {
            continueButton.isEnabled = false
            continueButton.alpha = 0.25
            agreementCheckbox.isSelected = false
        } else {
            continueButton.isEnabled = true
            continueButton.alpha = 1
            agreementCheckbox.isSelected = true
        }
    }

    @IBAction func showPassword(_ sender: UIButton) {
        if passwordTextField.isSecureTextEntry == true {
            passwordTextField.isSecureTextEntry = false
            sender.isSelected = true
        } else {
            passwordTextField.isSecureTextEntry = true
            sender.isSelected = false
        }
    }
    @IBAction func showPassword2(_ sender: UIButton) {
        if confirmPasswordTextField.isSecureTextEntry == true {
            confirmPasswordTextField.isSecureTextEntry = false
            sender.isSelected = true
        } else {
            confirmPasswordTextField.isSecureTextEntry = true
            sender.isSelected = false
        }
    }
    @IBAction func passwordChanged(_ sender: Any) {
        if let textField = sender as? UITextField {
            var currentBorderColor: UIColor = .red
            var defaultBorderColor: UIColor = .red
            switch PasswordStrength.checkStrength(password: textField.text ?? "") {
            case .None:
                inputPasswordLabel.text = "Введите пароль"
                inputPasswordLabel.textColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1)
                currentBorderColor = inputPasswordLabel.textColor
            defaultBorderColor = .clear
            case .Weak:
                inputPasswordLabel.text = "Ненадежный"
                inputPasswordLabel.textColor = UIColor(red: 0.92, green: 0.27, blue: 0.26, alpha: 1)
                currentBorderColor = inputPasswordLabel.textColor
            defaultBorderColor = inputPasswordLabel.textColor
            case .Moderate:
                inputPasswordLabel.text = "Средний"
                inputPasswordLabel.textColor = UIColor(red: 0.95, green: 0.68, blue: 0.45, alpha: 1)
                currentBorderColor = inputPasswordLabel.textColor
            defaultBorderColor = inputPasswordLabel.textColor
            case .Strong:
                inputPasswordLabel.text = "Надежный"
                inputPasswordLabel.textColor = UIColor(red: 0.13, green: 0.76, blue: 0.51, alpha: 1)
                currentBorderColor = inputPasswordLabel.textColor
            defaultBorderColor = inputPasswordLabel.textColor
            }
            passwordTextField.defaultBorderColor = defaultBorderColor
            passwordTextField.selectedBorderColor = currentBorderColor
            passwordTextField.layer.borderColor = currentBorderColor.cgColor
        }
    }

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
        phoneTextField.text = result
//        return false
    }


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        addGradientLayerView()
//        addCircleView()
        if pageControl != nil {
            setUpPageControl()
        }
        view.clipsToBounds = true

        if let head = header as? MaskedNavigationBar {
            head.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            head.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            head.gradientLayer.colors = [UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }

        phoneTextField.delegate = self

//        agreementLabel.textColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
//        let str = NSMutableAttributedString(string: "Я прочитал ", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Light", size: 13)!])
//        str.append((NSAttributedString(string: "условия банка", attributes: [NSAttributedString.Key.font : UIFont(name: "Roboto-Light", size: 13)!])))
//        agreementLabel.attributedText = str
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController as? ProfileNavigationController,
            pageControl != nil {
            if centralView.contentOffset.y == 0 {
                nav.pageControl.isHidden = false
                pageControl.isHidden = true
            } else {
                nav.pageControl.isHidden = true
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                nav.pageControl.setCurrentPage(at: 1)
            }, completion: nil)
        }
        if segueId == "loginPassword" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0)),
                HeroModifier.beginWith([HeroModifier.opacity(1)]),
                HeroModifier.opacity(0)
            ]
            header.hero.id = "head"
        }
        if segueId == "smsVerification" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0)),
                HeroModifier.beginWith([HeroModifier.opacity(1)]),
                HeroModifier.opacity(0)
            ]
            header.hero.id = "head"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = navigationController as? ProfileNavigationController,
            pageControl != nil {
            nav.pageControl.isHidden = true
            pageControl.isHidden = false
        }
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView?.hero.modifiers = nil
        header.hero.modifiers = nil
        header?.hero.id = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let nav = navigationController as? ProfileNavigationController,
            pageControl != nil {
            if centralView.contentOffset.y == 0 {
                nav.pageControl.isHidden = false
            } else {
                nav.pageControl.isHidden = true
            }
            pageControl.isHidden = true
        }
        if segueId == "loginPassword" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0)),
                HeroModifier.opacity(0)
            ]
            header.hero.id = "head"
        }
        if segueId == "smsVerification" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0)),
                HeroModifier.opacity(0)
            ]
            header.hero.id = "head"
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if pageControl != nil {
            pageControl.isHidden = false
        }
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView?.hero.modifiers = nil
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
        segueId = nil
        if let vc = segue.destination as? RegistrationCodeVerificationViewController {
            segueId = "smsVerification"
            vc.segueId = segueId
            vc.backSegueId = segueId
            vc.phone = phoneTextField.text
        }
    }
}

//MARK: - Private methods
private extension RegistrationLoginPasswordViewController {
    // MARK: - Methods
    func addGradientLayerView() {
        gradientView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        //        gradientView.alpha = 0
        view.insertSubview(gradientView, at: 0)
    }

    func addCircleView() {
        circleView.frame = CGRect(x: 0, y: 0, width: view.frame.width * 5, height: view.frame.width * 5)
        circleView.center = view.center
        circleView.frame.origin.y = UIDevice.hasNotchedDisplay ? 90 : 67
        circleView.backgroundColor = .clear
        let layer = CAShapeLayer()
        layer.path = CGPath(ellipseIn: circleView.bounds, transform: nil)
        layer.fillColor = UIColor.white.cgColor
        circleView.layer.addSublayer(layer)
        circleView.clipsToBounds = true
        view.insertSubview(circleView, at: 1)
    }

    func setUpPageControl() {
        pageControl.numberOfPages = 4
        pageControl.pageIndicatorTintColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 234 / 255, green: 68 / 255, blue: 66 / 255, alpha: 1)

        let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )

        pageControl.setConfig(config)
        pageControl.animateDuration = 0
        pageControl.setCurrentPage(at: 1)
    }
}


extension RegistrationLoginPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField,
            let text = textField.text,
            let textRange = Range(range, in: text) {

//            let updatedText = text.replacingCharacters(in: textRange,
//                                                       with: string)
//            let cleanPhoneNumber = updatedText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let set = CharacterSet(charactersIn: "+()- ").union(CharacterSet.decimalDigits)
            if (string.rangeOfCharacter(from: set.inverted) != nil) {
                return false
            }
//            let mask = "+X (XXX) XXX-XXXX"
//            if string.count + range.location > mask.count {
//                return false
//            }
//
//            var result = ""
//            var index = cleanPhoneNumber.startIndex
//            for ch in mask {
//                if index == cleanPhoneNumber.endIndex {
//                    break
//                }
//                if ch == "X" {
//                    result.append(cleanPhoneNumber[index])
//                    index = cleanPhoneNumber.index(after: index)
//                } else if ch == "+" || ch == "(" || ch == ")" || ch == "-" || ch == " " {
//                    result.append(ch)
//                } else {
////                    return false
//                }
//            }
//            if index != cleanPhoneNumber.endIndex {
//                return false
//            }
//            phoneTextField.text = result
//            return false
        }
        return true
    }

}

