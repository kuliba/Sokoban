//
//  RegistrationPermissionsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 01/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import FlexiblePageControl
import Hero
import LocalAuthentication
import ReSwift
import TOPasscodeViewController

class RegistrationPermissionsViewController: UIViewController, CAAnimationDelegate, StoreSubscriber {

    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var touchIdDevice: UIView!
    @IBOutlet weak var faceIdDevice: UIView!
    @IBOutlet var biometricSwitches: [UISwitch]!
    @IBOutlet weak var passcodeSwitch: UISwitch!
    let pushNotificationParamets = [
    "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
    "pushFCMtoken": FCMToken.fcmToken as Any,
    "model": UIDevice().model,
     "operationSystem": "IOS"
    ] as [String : Any]
    // MARK: - Actions

    @IBAction func backButtonCLicked(_ sender: Any) {
        segueId = backSegueId
        view.endEditing(true)

        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func biometricSwitchChanged(_ sender: UISwitch) {
        registrationSettings.allowBiometric = sender.isOn
        if sender.isOn == true {
            performSegue(withIdentifier: "touchID", sender: nil)
        }
    }

    @IBAction func passcodeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn == true {
            store.dispatch(startPasscodeSingUp)
        } else {
            store.dispatch(clearSignUpProcess)
        }
        registrationSettings.allowPasscode = sender.isOn
        registrationSettings.allowPasscode ? nil : (registrationSettings.allowBiometric = false)
    }

    @IBAction func `continue`(_ sender: Any) {
        NetworkManager.shared().doRegistration(completionHandler: { [unowned self] success, errorMessage, l, p in
            if success {
                NetworkManager.shared().login(login: l ?? "", password: p ?? "", completionHandler: { (success, error) in
                    if success {
                        store.dispatch(registrationSettingsCreated(registrationSettings: self.registrationSettings))
                        self.performSegue(withIdentifier: "authSms", sender: nil)
                    } else {
                        let alert = UIAlertController(title: "Неудачная авторизация", message: "", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        let rootVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginOrSignupViewController") as! LoginOrSignupViewController

                        self.navigationController?.setViewControllers([rootVC], animated: true)
                    }
                })
            } else {
                let alert = UIAlertController(title: "Неудача", message: errorMessage?.description, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

    var segueId: String? = nil
    var backSegueId: String? = nil
    let gradientView = UIView()
    let circleView = UIView()
    let touchMe = BiometricIDAuth()
    let context = LAContext()
    var registrationSettings = RegistrationSettings() {
        didSet {
            updateViews()
        }
    }

    func biometricType() -> BiometricType {
        let canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if !canEvaluatePolicy {
            biometricSwitches.forEach { $0.isEnabled = false }
        }
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            fatalError()
        }
    }

    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setUpContinueButton()
        addGradientLayerView()
//        addCircleView()
        if pageControl != nil {
            setUpPageControl()
        }
        view.clipsToBounds = true


        switch touchMe.biometricType() {
        case .faceID:
            touchIdDevice.isHidden = true
        default:
            faceIdDevice.isHidden = true
        }

        updateViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParent {
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                nav.pageControl.isHidden = false
                pageControl.isHidden = true
                UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                    nav.pageControl.setCurrentPage(at: 3)
                }, completion: nil)
            }
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
            ]
        } else {
            if let nav = navigationController as? ProfileNavigationController {
                nav.pageControl.isHidden = true
                pageControl.isHidden = false
            }
            containerView.hero.id = "content"
            containerView.hero.modifiers = [
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
            header?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        store.subscribe(self) { state in
            state.select { $0 }
        }

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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if segueId == "touchID" {
            if let nav = navigationController as? ProfileNavigationController {
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
                nav.pageControl.isHidden = false
                pageControl.isHidden = true
            }
            containerView.hero.id = "content"
            view.hero.id = "view"
            centralView?.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x + view.frame.width, y: 0))
            ]
        } else {
//            if let nav = navigationController as? ProfileNavigationController {
//                nav.pageControl.isHidden = true
//                pageControl.isHidden = false
//            }
//            containerView.hero.modifiers = [
//                HeroModifier.beginWith([
//                    HeroModifier.opacity(1),
//                    HeroModifier.zPosition(2)
//                    ]),
//                HeroModifier.duration(0.5),
//                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height)),
//            ]
//            gradientView.hero.modifiers = [
//                HeroModifier.duration(0.5),
//                HeroModifier.opacity(0)
//            ]
//            header?.hero.modifiers = [
//                HeroModifier.duration(0.5),
//                HeroModifier.opacity(0)
//            ]
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                nav.pageControl.isHidden = true
                pageControl.isHidden = false
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
        store.unsubscribe(self)

        pageControl.isHidden = true
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView?.hero.modifiers = nil
        gradientView.hero.modifiers = nil
        header?.hero.modifiers = nil
    }

    func newState(state: State) {
        if state.passcodeSignUpState.isStarted == true {
            let passcodeVC = PasscodeSignUpViewController()
            passcodeVC.modalPresentationStyle = .fullScreen
            passcodeVC.passcodeDelegate = self
            present(passcodeVC, animated: true, completion: nil)
        }
    }

    func updateViews() {

        biometricSwitches.forEach { [weak self] (switchView) in
            guard let allowPasscode = self?.registrationSettings.allowPasscode, let allowBiometric = self?.registrationSettings.allowBiometric else {
                return
            }
            switchView.isEnabled = allowPasscode
            switchView.isOn = allowPasscode ? allowBiometric : false
        }

        passcodeSwitch.isOn = registrationSettings.allowPasscode

        if registrationSettings.allowPasscode {
            continueButton.setTitle("Готово", for: .normal)
        } else {
            continueButton.setTitle("Настроить позже", for: .normal)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueId = nil
        if let vc = segue.destination as? RegistrationCodeVerificationViewController {
            segueId = "auth"
            vc.segueId = segueId
        }
        if let vc = segue.destination as? RegistrationTouchIDViewController {
            segueId = "touchID"
            vc.segueId = segueId
            vc.biometricDelegate = self
        }
    }
}

// MARK: - Private methods
private extension RegistrationPermissionsViewController {

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

        /*let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )*/

        //pageControl.setConfig(config)
        pageControl.setCurrentPage(at: 3)
    }

    func setUpContinueButton() {
        continueButton.backgroundColor = .clear
        continueButton.setTitleColor(.black, for: [])
        continueButton.layer.borderWidth = 1
        continueButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.25).cgColor
    }
}

extension RegistrationPermissionsViewController: RegistrationTouchIDViewControllerDelegate {
    func passcodeFinished(success: Bool) {
        registrationSettings.allowBiometric = success
    }
}

extension RegistrationPermissionsViewController: PasscodeSignUpViewControllerDelegate {
    func biometricFinished(success: Bool) {
        registrationSettings.allowPasscode = success
    }
}
