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

class RegistrationCodeVerificationViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var codeNumberTextField: UITextField!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView?

    var segueId: String? = nil
    var backSegueId: String? = nil

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

    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        view.endEditing(true)
        segueId = backSegueId
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func authContinue(_ sender: Any) {
        view.endEditing(true)
        activityIndicator?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().checkVerificationCode(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
            self?.continueButton.isHidden = false
            self?.activityIndicator?.stopAnimating()
            if success {
                store.dispatch(finishVerification)
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

    @IBAction func regContinue(_ sender: Any) {
        guard let str = self.codeNumberTextField.text,
            let code = Int(str) else {

                return
        }
        activityIndicator?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().verifyCode(verificationCode: code) { [weak self] (success, errorMessage) in
            self?.continueButton.isHidden = false
            self?.activityIndicator?.stopAnimating()
            if success {
                self?.performSegue(withIdentifier: "regPermissions", sender: nil)
            } else {
                let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func firstAuth(_ sender: Any) {
        activityIndicator?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().checkVerificationCode(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
            self?.continueButton.isHidden = false
            self?.activityIndicator?.stopAnimating()
            if success {
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
        activityIndicator?.startAnimation()
        continueButton.isHidden = true
        NetworkManager.shared().makeCard2Card(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
            self?.continueButton.isHidden = false
            self?.activityIndicator?.stopAnimating()
            if success {
                self?.performSegue(withIdentifier: "finish", sender: nil)
            } else {
                let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
                    let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "PaymentsFinishScreen") as! LoginOrSignupViewController
                    self?.segueId = "dismiss"
                    rootVC.segueId = "logout"
                    self?.navigationController?.setViewControllers([rootVC], animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    func newState(state: VerificationCodeState) {
        guard state.isShown == true else {
            return
        }
        backButton.isHidden = true
    }

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
            head.gradientLayer.colors = [UIColor(red: 237 / 255, green: 73 / 255, blue: 73 / 255, alpha: 1).cgColor, UIColor(red: 241 / 255, green: 176 / 255, blue: 116 / 255, alpha: 1).cgColor]
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
        if segueId == "smsVerification" || segueId == "auth" {
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
            ]
            header.hero.id = "head"
        }
        if segueId == "permissions" {
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
        }
        if segueId == "smsVerification" {
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
//                HeroModifier.zPosition(0)
            ]
        }
        if segueId == "permissions" {
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
        segueId = nil
        if let vc = segue.destination as? RegistrationPermissionsViewController {
            segueId = "permissions"
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
        if let vc = segue.destination as? RegistrationFinishViewController {
            segueId = "finish"
            vc.segueId = segueId
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
            gradientLayer.colors = [UIColor(red: 237 / 255, green: 73 / 255, blue: 73 / 255, alpha: 1).cgColor, UIColor(red: 241 / 255, green: 176 / 255, blue: 116 / 255, alpha: 1).cgColor]
        } else {
            gradientLayer.colors = [UIColor(red: 241 / 255, green: 176 / 255, blue: 116 / 255, alpha: 1).cgColor, UIColor(red: 237 / 255, green: 73 / 255, blue: 73 / 255, alpha: 1).cgColor]
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

        let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )

        pageControl.setConfig(config)
        pageControl.animateDuration = 0
        pageControl.setCurrentPage(at: 2)
//        pageControl.center.x = view.center.x
//        pageControl.frame.origin.y = 40
//        containerView.addSubview(pageControl)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let set = CharacterSet.decimalDigits
        if (string.rangeOfCharacter(from: set.inverted) != nil) {
            return false
        }
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        continueButton?.isEnabled = count >= 3
        continueButton?.alpha = (count >= 3) ? 1 : 0.25
        return true
    }
}
