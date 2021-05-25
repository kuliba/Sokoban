//
//  RegistrationCodeVerificationViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import FlexiblePageControl
import Hero
import ReSwift
import Alamofire
import Security
import UIKit


class RegistrationCodeVerificationViewController: UIViewController, StoreSubscriber, PreparePaymentDelegate {
    func preparePayment(_ preparePayment: DataClassPayment) {
        print(preparePayment)
    }
    

    @IBOutlet weak var maskNumberCardLabel: UILabel!
    @IBOutlet weak var phoneLable: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var comissionLabel: UILabel!
    var currencyLable: String?
    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var codeNumberTextField: UITextField!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView?
    @IBAction func repeatCode(_ sender: Any) {
//        guard let dataUserEncrypt = keychainCredentialsUserData() else { return  }
//        let dataUser =  keychainCredentialsUserData()
//        saveUserDataToKeychain(userData: dataUserEncrypt)
        
//        store.dispatch(createCredentials(login: self.login ?? "", pwd: self.password ?? ""))
        guard let encryptedUserData = keychainCredentialsUserData() else {
            return
        }
        var userData: UserData?
        let passcode = keychainCredentialsPasscode()
        userData = decryptUserData(userData: encryptedUserData, withPossiblePasscode: passcode ?? "")
       
        userData = decryptUserData(userData: encryptedUserData, withPossiblePasscode: passcode ?? "")
        if userData != nil {
            self.login = userData?.login
            self.password = userData?.pwd
            
        }
        NetworkManager.shared().login(login:  cleanNumber(number: self.login)!,
                                      password: self.password!,
                                        completionHandler: { [unowned self] success, errorMessage in
                                            if success {
                                                store.dispatch(createCredentials(login: self.login ?? "", pwd: self.password ?? ""))
                                            } else {
                                                AlertService.shared.show(title: "Ошибка", message: errorMessage ?? "Повторите позднее", cancelButtonTitle: "Ок", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
                                            }
                                        })

    }
    
    var segueId: String? = nil
    var operationSum: String?
    var ownerCard: String?
    var commission: String?
    var sourceConfigurations: [ICellConfigurator]?
    var destinationConfigurations: [ICellConfigurator]?
    var login: String?
    var password: String?
    
    @IBOutlet weak var authForaPreloader: RefreshView!
    @IBOutlet weak var foraPreloader: RefreshView!
    let gradientView = UIView()
    let circleView = UIView()
//    var message: String? = nil
    var phone: String? = nil //{
//        didSet {
//            if let newValue = phone {
//                let fromIndex = newValue.index(newValue.endIndex, offsetBy: -8)
//                let toIndex = newValue.index(newValue.endIndex, offsetBy: -2)
//                message = "Введите код, который мы прислали на номер \(newValue.replacingCharacters(in: fromIndex..<toIndex, with: "*****"))"
//            }
//        }
//    }
    var backSegueId: String? = nil
    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        view.endEditing(true)
        segueId = backSegueId
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    
    
    
    
    @IBAction func authContinue(_ sender: Any) {
        view.endEditing(true)
        foraPreloader.isHidden = false
        foraPreloader?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().checkVerificationCode(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
            self?.continueButton.isHidden = false
            self?.foraPreloader?.isHidden = false
            if success {
                
                if Core.shared.isNewUser(){
                   let alert = UIAlertController.init(title: "hello", message: "message", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Done", style: .default, handler: { (action) -> Void in
                           print("Ok button tapped")
                       })
                    alert.addAction(okButton)
                    print("NewUser")
                    self!.present(alert, animated: true, completion: nil)

                } else {
                        store.dispatch(finishVerification)
                }
                
            } else {
                self?.foraPreloader?.isHidden = true
                let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
                    let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginOrSignupViewController") as! LoginOrSignupViewController
                    self?.segueId = "dismiss"
                    rootVC.segueId = "logout"
                    self?.navigationController?.setViewControllers([rootVC], animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    @IBAction func resetPasswordCheckCode(_ sender: Any) {
        view.endEditing(true)
        
        continueButton.isHidden = true
        NetworkManager.shared().checkCodeResetPassword(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
            self?.continueButton.isHidden = false
            if success {
                self?.performSegue(withIdentifier: "newPasswordReset", sender: self)

            } else {
                let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func regContinue(_ sender: Any) {
        guard let str = self.codeNumberTextField.text,
            let code = Int(str) else {

                return
        }
        foraPreloader.isHidden = false
        foraPreloader?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().verifyCode(verificationCode: code) { [weak self] (success, errorMessage) in
            self?.continueButton.isHidden = false
            self?.foraPreloader?.isHidden = true
            if success {
                self?.performSegue(withIdentifier: "fromRegistrationVerificationToPermissions", sender: nil)
            } else {
                let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func firstAuth(_ sender: Any) {
        authForaPreloader.isHidden = false
        authForaPreloader?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().checkVerificationCode(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
            self?.continueButton.isHidden = false
            self?.authForaPreloader?.isHidden = true
            if success {
                store.dispatch(finishPasscodeSingUp)
                self?.performSegue(withIdentifier: "finish", sender: nil)
            } else {
                let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
                    let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginOrSignupViewController") as! LoginOrSignupViewController
                    self?.segueId = "dismiss"
                    rootVC.segueId = "logout"
                    self?.navigationController?.setViewControllers([rootVC], animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func checkPaymentCode(_ sender: Any) {
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimation()
//        codeNumberTextField.addSubview(activityIndicator ?? view)
        continueButton.isHidden = true
        if segueId == "serviceOperation"{
            NetworkManager.shared().anywayPaymentMake(code: "\(self.codeNumberTextField.text ?? "")") { (success, errorMessage) in
                if success {
                    self.activityIndicator?.isHidden = true
                    self.activityIndicator?.stopAnimating()
//                    store.dispatch(finishPasscodeSingUp)
                    self.performSegue(withIdentifier: "finish", sender: nil)
//                    self?.performSegue(withIdentifier: "finish", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Неудача", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
//                        let rootVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentsFinishScreen") as! LoginOrSignupViewController
//                        self.segueId = "dismiss"
//                        rootVC.segueId = "logout"
//                        self.navigationController?.setViewControllers([rootVC], animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.continueButton.isHidden = false
                    self.activityIndicator?.isHidden = true
                    self.activityIndicator?.stopAnimating()
                }
            }
        } else if segueId == "contactViewController"{
            NetworkManager.shared().anywayPaymentMake(code: "\(self.codeNumberTextField.text ?? "")") { [self] (success, errorMessage) in
                if success {
                    self.activityIndicator?.isHidden = true
                    self.activityIndicator?.stopAnimating()
//                    store.dispatch(finishPasscodeSingUp)
//                    self.performSegue(withIdentifier: "finish", sender: nil)
//                    guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentsFinishScreen") as? PaymentsDetailsSuccessViewController else {
//                                             return
//                    }
//                    guard let sumUnwrapped = Double(operationSum ?? "0.0") else {
//                        return
//                    }
//                    vc.destinationValue = PaymentOption(id: 0.0, name: "Перевод по системе контакт", type: .paymentOption, sum: sumUnwrapped, number: ownerCard ?? "", maskedNumber: ownerCard ?? "", provider: "", productType: .card, maskSum: sumLabel.text ?? "", currencyCode: "", accountNumber: "", productName: "")
//                    present(vc, animated: true, completion: nil)
//
                    self.performSegue(withIdentifier: "finish", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Неудача", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
//                        let rootVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentsFinishScreen") as! LoginOrSignupViewController
//                        self.segueId = "dismiss"
//                        rootVC.segueId = "logout"
//                        self.navigationController?.setViewControllers([rootVC], animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.continueButton.isHidden = false
                    self.activityIndicator?.isHidden = true
                    self.activityIndicator?.stopAnimating()
                }
            }
        } else{
            NetworkManager.shared().makeCard2Card(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
                self?.continueButton.isHidden = false
                self?.activityIndicator?.isHidden = true
                if success {
                    self?.performSegue(withIdentifier: "finish", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
//                        let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "PaymentsFinishScreen") as! LoginOrSignupViewController
//                        self?.segueId = "dismiss"
//                        rootVC.segueId = "logout"
//                        self?.navigationController?.setViewControllers([rootVC], animated: true)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                    self?.continueButton.isHidden = true
                    self?.activityIndicator?.isHidden = true
                    self?.activityIndicator?.stopAnimating()
                }
            }
        }
        
 
    }

    var sourceConfig: Any?
    var sourceValue: Any?
    var destinationConfig: Any?
    var destinationValue: Any?

    func newState(state: VerificationCodeState) {
        guard state.isShown == true else {
            return
        }
        backButton.isHidden = true
    }

    func maskWithStars(_ number: String) {
        let count = number.count
        switch count {
        case 20:
            let cleanNumber = number.dropFirst(16)
            self.maskNumberCardLabel.text = "**** \(cleanNumber )"
        case 16:
            let cleanNumber = number.dropFirst(12)
            self.maskNumberCardLabel.text = "**** \(cleanNumber )"
//        case 11:
//            self.maskNumberCardLabel.text =
        default:
            break
        }
    }
    @IBOutlet weak var recipient: UILabel!
    @IBOutlet weak var sumTransferLabel: UILabel!
    
    var numberTransferValue: String?
    var amountRurCurrently: String?
    var countryValue: String?
    @IBOutlet weak var numberTransferLabel: UILabel!
    
    @IBOutlet weak var numberTransferValueLabel: UILabel!
    // MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = codeNumberTextField.becomeFirstResponder()
        addGradientLayerView()
//        addCircleView()
        if pageControl != nil {
            setUpPageControl()
        }
        
        codeNumberTextField.delegate = self
        
        view.clipsToBounds = true

        if let head = header as? MaskedNavigationBar {
            head.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            head.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            head.gradientLayer.colors = [UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }
//        messageLabel?.text = message

        store.subscribe(self) {
            return $0.select { $0.verificationCodeState }
        }
        switch segueId {
        case "fromPaymentToPaymentVerification":
            phoneLable.isHidden = true
            numberTransferValueLabel.isHidden = true
            numberTransferLabel.isHidden = true
            self.ownerLabel.text = ownerCard
            self.comissionLabel.text = "\(commission ?? "0") \(self.currencyLable ?? "₽")"
            self.sumLabel.text = "\(operationSum!) \(self.currencyLable ?? "₽")"
            guard let numberCard = (sourceValue as? PaymentOption)?.number else { return }
            maskWithStars(numberCard)
            if (destinationValue as? String)?.rangeOfCharacter(from: ["9"]) != nil{
            if (destinationValue as? PaymentOption)?.number.count == 11{
                self.phoneLable.text = formattedPhoneNumber(number: ((destinationValue as? String)!))
            } else if (destinationValue as? String)?.count == 20 {
                self.phoneLable.text = "**** \((destinationValue as? String)?.dropFirst(16) ?? "")"
            } else if (destinationValue as? String)?.count == 16 {
                self.phoneLable.text = "**** \((destinationValue as? String)?.dropFirst(12) ?? "")"
            } else if (destinationValue as? String)?.count == 11 {
                self.phoneLable.text = formattedPhoneNumber(number: ((destinationValue as? String)!))
            } else if (destinationValue as? PaymentOption)?.number.count == 16{
                self.phoneLable.text = "**** \((destinationValue as? PaymentOption)?.number.dropFirst(12) ?? "")"
            } else if (destinationValue as? PaymentOption)?.number.count == 20{
                self.phoneLable.text = "**** \((destinationValue as? PaymentOption)?.number.dropFirst(16) ?? "")"
            }else if (destinationValue as? String)?.count == 17{
                self.phoneLable.text = (destinationValue as? String)
            } else {
                self.phoneLable.text = "**** \((destinationValue as? String)?.dropFirst(12) ?? "")"
            }
            } else {
                self.phoneLable.text = "\((destinationValue as? String) ?? "Получатель не найден")"
            }
        case "contactViewController","serviceOperation":
            
            guard let numberCard = (sourceValue as? PaymentOption)?.number else { break }
            maskWithStars(numberCard)
            recipient.text = "Получатель / Страна выдачи"
            sumTransferLabel.text = "Сумма в валюте выдачи / списания"
            self.ownerLabel.text = ownerCard
            var currencyLabelParse = getSymbol(forCurrencyCode: self.currencyLable ?? "₽")
            if currencyLabelParse == "р."{
                currencyLabelParse = "₽"
            }
            self.comissionLabel.text = "\(commission ?? "0") \(currencyLabelParse ?? "₽")"
          
            self.sumLabel.text = "\(operationSum ?? "")  \(currencyLabelParse ?? "₽")" + " / " + "\(amountRurCurrently ?? "")₽ "
            numberTransferValueLabel.text = numberTransferValue
            guard let destinationRecipient = destinationValue else {
                break
            }
            guard let countryUnwrapped = countryValue else {
                break
            }
            phoneLable.text = "\(destinationRecipient)" + " / " + "\(countryUnwrapped)"
            
        default:
            break
        }
        _ = codeNumberTextField.becomeFirstResponder()
        addGradientLayerView()
//        addCircleView()
        if pageControl != nil {
            setUpPageControl()
        }
        
        codeNumberTextField.delegate = self
        
        view.clipsToBounds = true

        if let head = header as? MaskedNavigationBar {
            head.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            head.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            head.gradientLayer.colors = [UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }
//        messageLabel?.text = message

        store.subscribe(self) {
            return $0.select { $0.verificationCodeState }
        }
    }

      
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController as? ProfileNavigationController,
            pageControl != nil {
            if nav.pageControl.isHidden {
                pageControl.isHidden = false
                pageControl.hero.modifiers = [
                    HeroModifier.duration(0.5),
                    HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
                ]
            } else {
                pageControl.isHidden = true
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                nav.pageControl.setCurrentPage(at: 2)
            }, completion: nil)
        }
        if isMovingToParent {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
            ]
            header.hero.id = "head"
        } else {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
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
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)

        if segueId == "dismiss" {
            containerView.hero.id = "content"
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(2)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height)),
            ]
            gradientView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
            header?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
            return
        }
        if segueId == "finish" {
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                nav.pageControl.isHidden = true
                pageControl.isHidden = false
            }
            containerView.hero.id = "content"
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(2)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height)),
            ]
            gradientView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
            header?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
            return
        }
        if isMovingFromParent {
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                print("sms vc \(nav.pageControl.isHidden)")
                nav.pageControl.isHidden = true
                pageControl.isHidden = true
            }
            containerView.hero.id = "content"
            view.hero.id = "view"
            header.hero.id = "head"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0)),
            ]
        } else {
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                nav.pageControl.isHidden = false
                pageControl.isHidden = true
            }
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView?.hero.modifiers = nil
        gradientView.hero.modifiers = nil
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
    if let vc = segue.destination as? RegistrationPermissionsViewController {
            segueId = "permissions"
            vc.segueId = segueId
            vc.backSegueId = segueId
        } else if let vc = segue.destination as? RegistrationFinishViewController {
            segueId = "finish"
            vc.segueId = segueId
        } else  if let destinationVC = segue.destination as? PaymentsDetailsSuccessViewController, segueId != "contactViewController" {
            destinationVC.currentLabel = currencyLable
            destinationVC.sourceConfig = sourceConfig
            destinationVC.sourceValue = sourceValue
            destinationVC.destinationConfig = nil
            destinationVC.destinationValue = destinationValue
            destinationVC.operationSum = operationSum
            destinationVC.currentLabel = (sourceValue as? PaymentOption)?.currencyCode
            destinationVC.destinationValue =  PaymentOption(id: 0.0, name: "Адресный перевод", type: .paymentOption, sum: 0.0, number: phoneLable.text ?? "", maskedNumber: ownerCard ?? "", provider: "", productType: .card, maskSum: sumLabel.text ?? "", currencyCode: currencyLable ?? "RUR", accountNumber: "", productName: "")
        } else  if let destinationVC = segue.destination as? PaymentsDetailsSuccessViewController, segueId == "contactViewController" {
//            guard let sumUnwrapped = Double(operationSum ?? "0.0")  else {
//                return
//            }
            destinationVC.currentLabel = currencyLable
            destinationVC.sourceConfig = destinationConfig
            destinationVC.sourceValue = sourceValue
            destinationVC.sourceConfig = sourceConfig
            destinationVC.destinationConfig = nil
            destinationVC.destinationValue =  PaymentOption(id: 0.0, name: "Безадресный перевод", type: .paymentOption, sum: 0.0, number: phoneLable.text ?? "", maskedNumber: ownerCard ?? "", provider: "", productType: .card, maskSum: sumLabel.text ?? "", currencyCode: currencyLable ?? "RUR", accountNumber: "", productName: "")
            destinationVC.operationSum = operationSum
        }
    }
}

// MARK: - Private methods
extension RegistrationCodeVerificationViewController: UITextFieldDelegate {
    
        
    func addGradientLayerView() {
        gradientView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        if header is MaskedNavigationBar {
            gradientLayer.colors = [UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor]
        } else {
            gradientLayer.colors = [UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 64 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }
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

        /*let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )*/

        //pageControl.setConfig(config)
        pageControl.animateDuration = 0
        pageControl.setCurrentPage(at: 2)
//        pageControl.center.x = view.center.x
//        pageControl.frame.origin.y = -140
//        containerView.addSubview(pageControl)
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        let count = codeNumberTextField.text!.count + string.count - range.length

        if  count == 6{
        
            codeNumberTextField.text = codeNumberTextField.text! + string
             continueButton.sendActions(for: .allEvents)
        
        }

        let set = CharacterSet.decimalDigits
        if (string.rangeOfCharacter(from: set.inverted) != nil) {
            return false
        }
        guard let text = textField.text else { return true }
        continueButton?.isEnabled = count >= 6
        continueButton?.alpha = (count >= 6) ? 1 : 0.25
        codeNumberTextField.text =  text
   
        _ = String(codeNumberTextField.text!)

        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 6

        //return true
    }
    
    
}
extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
    }
}

