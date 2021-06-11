//
//  AppALConstants.swift
//  AppLocker
//
//  Created by Oleg Ryasnoy on 07.07.17.
//  Copyright © 2017 Oleg Ryasnoy. All rights reserved.
//

import UIKit
import AudioToolbox
import LocalAuthentication
import Valet
import FirebaseMessaging

public enum ALConstants {
    static let nibName = "AppLocker"
    static let kPincode = "pincode" // Key for saving pincode to keychain
    static let kLocalizedReason = "Unlock with sensor" // Your message when sensors must be shown
    static let duration = 0.3 // Duration of indicator filling
    static let maxPinLength = 4
    
    enum button: Int {
        case delete = 1000
        case cancel = 1001
    }
}

public typealias onSuccessfulDismissCallback = (_ mode: ALMode?) -> () // Cancel dismiss will send mode as nil
public typealias onFailedAttemptCallback = (_ mode: ALMode) -> ()
public struct ALOptions { // The structure used to display the controller
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public var color: UIColor?
    public var isSensorsEnabled: Bool?
    public var onSuccessfulDismiss: onSuccessfulDismissCallback?
    public var onFailedAttempt: onFailedAttemptCallback?
    public init() {}
}

public enum ALMode { // Modes for AppLocker
    case validate
    case change
    case deactive
    case create
}

public class AppLocker: UIViewController {
    
    // MARK: - Top view
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submessageLabel: UILabel!
    @IBOutlet var pinIndicators: [Indicator]! {
        didSet {
            pinIndicators.forEach { pinIndicator in
                pinIndicator.layer.cornerRadius = 6
            }
        }
    }
    
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            buttons.forEach { button in
                button.layer.cornerRadius = button.layer.bounds.height / 2
            }
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = cancelButton.layer.bounds.height / 2
        }
    }
    
    static let valet = Valet.valet(with: Identifier(nonEmpty: "Druidia")!, accessibility: .whenUnlockedThisDeviceOnly)
    // MARK: - Pincode
    private var onSuccessfulDismiss: onSuccessfulDismissCallback?
    private var onFailedAttempt: onFailedAttemptCallback?
    private let context = LAContext()
    private var pin = "" { // Entered pincode
        didSet {
//            print("DEBUG: det my pin is: ", pin)
        }
    }
    private var reservedPin = "" // Reserve pincode for confirm
    private var isFirstCreationStep = true
    private var savedPin: String? {
        get {
            return try? AppLocker.valet.string(forKey: ALConstants.kPincode)
        }
        set {
            guard let newValue = newValue else { return }
            
//            sendMyPin(with: newValue)
            try? AppLocker.valet.setString(newValue, forKey: ALConstants.kPincode)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // https://stackoverflow.com/questions/56459329/disable-the-interactive-dismissal-of-presented-view-controller-in-ios-13
        modalPresentationStyle = .fullScreen
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate var mode: ALMode = .validate {
        didSet {
            switch mode {
            case .create:
                cancelButton.isHidden = true
                submessageLabel.text = "Придумайте код из 4х цифр" // Your submessage for create mode
                print("DEBUG: API создать пароль")
            case .change:
                cancelButton.isHidden = true
                submessageLabel.text = "Введите код" // Your submessage for change mode
                print("DEBUG: API изменить пароль")
            case .deactive:
                cancelButton.isHidden = true
                submessageLabel.text = "Введите код" // Your submessage for deactive mode
            
            case .validate:
                submessageLabel.text = "Введите код" // Your submessage for validate mode
                cancelButton.isHidden = true
                isFirstCreationStep = false
                print("DEBUG: API проверить пароль и войти")
            }
        }
    }
    
    private func precreateSettings () { // Precreate settings for change mode
        mode = .create
        clearView()
    }
    
    private func drawing(isNeedClear: Bool, tag: Int? = nil) { // Fill or cancel fill for indicators
        let results = pinIndicators.filter { $0.isNeedClear == isNeedClear }
        let pinView = isNeedClear ? results.last : results.first
        pinView?.isNeedClear = !isNeedClear
        
        UIView.animate(withDuration: ALConstants.duration, animations: {
            pinView?.backgroundColor = isNeedClear ? #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1) : .black
        }) { _ in
            isNeedClear ? self.pin = String(self.pin.dropLast()) : self.pincodeChecker(tag ?? 0)
        }
    }
    
    private func pincodeChecker(_ pinNumber: Int) {
        if pin.count < ALConstants.maxPinLength {
            pin.append("\(pinNumber)")
            if pin.count == ALConstants.maxPinLength {
                switch mode {
                case .create:
                    createModeAction()
                case .change:
                    changeModeAction()
                case .deactive:
                    deactiveModeAction()
                case .validate:
                    validateModeAction()
                }
            }
        }
    }
    
    // MARK: - Modes
    private func createModeAction() {
        if isFirstCreationStep {
            isFirstCreationStep = false
            reservedPin = pin
            clearView()
            submessageLabel.text = "Подтвердите код"
        } else {
            confirmPin()
        }
    }
    
    private func changeModeAction() {
        if pin == savedPin {
            precreateSettings()
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func deactiveModeAction() {
        if pin == savedPin {
            removePin()
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func validateModeAction() {
        if pin == savedPin {
            guard let pin = savedPin else { return }
            login(with: pin, type: .pin) { error in
                if let error = error {
                    print(error)
                } else {
                    self.onSuccessfulDismiss?(self.mode)
                }
            }
            
//            dismiss(animated: true) {
//                self.onSuccessfulDismiss?(self.mode)
//            }
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func removePin() {
        try? AppLocker.valet.removeObject(forKey: ALConstants.kPincode)
//        dismiss(animated: true) {
            self.onSuccessfulDismiss?(self.mode)
//        }
    }
    
    private func confirmPin() {
        if pin == reservedPin {
            savedPin = pin
            switch mode {
            case .create:
                guard let pin = savedPin else { return }
                registerMyPin(with: pin) { error in
                    if let error = error {
                        print(error)
                        self.showAlert(with: "Ошибка", and: error)
                    } else {
                        self.onSuccessfulDismiss?(self.mode)
                    }
                }
            case .validate:
                guard let pin = savedPin else { return }
                login(with: pin, type: .pin) { error in
                    if let error = error {
                        print(error)
                    } else {
                        self.onSuccessfulDismiss?(self.mode)
                    }
                }
            case .change, .deactive:
                self.onSuccessfulDismiss?(self.mode)
            }
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func incorrectPinAnimation() {
        pinIndicators.forEach { view in
            view.shake(delegate: self)
//            view.backgroundColor = .clear
            view.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
            
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    fileprivate func clearView() {
        pin = ""
        pinIndicators.forEach { view in
            view.isNeedClear = false
            UIView.animate(withDuration: ALConstants.duration, animations: {
                view.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
            })
        }
    }
    
    // MARK: - Touch ID / Face ID
    fileprivate func checkSensors() {
        if case .validate = mode {} else { return }
        guard let pin = try? AppLocker.valet.string(forKey: ALConstants.kPincode) else { return }

        var policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics // iOS 8+ users with Biometric and Custom (Fallback button) verification
        
        // Depending the iOS version we'll need to choose the policy we are able to use
        
        // iOS 9+ users with Biometric and Passcode verification
        policy = .deviceOwnerAuthentication
        
        var err: NSError?
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy, error: &err) else {return}
        let biometricType = biometricType()
        // The user is able to use his/her Touch ID / Face ID 👍
        context.evaluatePolicy(policy, localizedReason: ALConstants.kLocalizedReason, reply: {  success, error in
            if success {
                self.login(with: pin, type: biometricType) { error in
                    if let error = error {
                        print(error)
                        self.showAlert(with: "Ошибка", and: error)
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else { return }
//                            self.dismiss(animated: true) {
                                self.onSuccessfulDismiss?(self.mode)
//                            }
                        }
                    }
                }
                
            }
        })
    }
    
    // MARK: - Keyboard
    @IBAction func keyboardPressed(_ sender: UIButton) {
        switch sender.tag {
        case ALConstants.button.delete.rawValue:
            drawing(isNeedClear: true)
        case ALConstants.button.cancel.rawValue:
            clearView()
//            dismiss(animated: true) {
                self.onSuccessfulDismiss?(nil)
//            }
        default:
            drawing(isNeedClear: false, tag: sender.tag)
        }
    }
    
}

extension AppLocker {
    //MARK: - API
    func registerMyPin(with code: String, completion: @escaping (_ error: String?) ->() ) {
        
        let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
        let biometricType = biometricType()
        
        let data = [
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFcmToken": Messaging.messaging().fcmToken! as String,
            "serverDeviceGUID" : serverDeviceGUID,
            "settings": [ ["type" : "pin",
                           "isActive": true,
                           "value": code],
                          ["type" : "touchId",
                           "isActive": biometricType == BiometricType.touchId ? true : false,
                           "value": code],
                          ["type" : "faceId",
                           "isActive": biometricType == BiometricType.faceId ? true : false,
                           "value": code] ] ] as [String : AnyObject]
//        print("DEBUG: data: ", data)
        NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, [:], data) { model, error in
            if error != nil {
                guard let error = error else { return }
                completion(error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    UserDefaults.standard.set(true, forKey: "UserIsRegister")
                    SceneDelegate.shared.getCSRF { error in
                        if error != nil {
                            print("DEBUG: Error getCSRF: ", error!)
                        } else {
                            self.login(with: code, type: .pin) { error in
                                if error != nil {
                                    completion(error!)
                                    print("DEBUG: Error getCSRF: ", error!)
                                } else {
                                    completion(nil)
                                }
                            }
                        }
                    }
                } else {
                    guard let error = model?.errorMessage else { return }
                    completion(error)
                }
            }
        }
    }
    
    func login(with code: String, type: BiometricType, completion: @escaping (_ error: String?) ->() ) {
        let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
        let data = [
            "appId": "IOS",
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFcmToken": Messaging.messaging().fcmToken! as String,
            "serverDeviceGUID": serverDeviceGUID,
            "loginValue": code,
            "type": type.rawValue
        ] as [String : AnyObject]

        NetworkManager<LoginDoCodableModel>.addRequest(.login, [:], data) { model, error in
            if error != nil {
                guard let error = error else { return }
                completion(error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    print("DEBUG: You are LOGGIN!!!")
                    completion(nil)
                } else {
                    guard let error = model?.errorMessage else { return }
                    completion(error)
                }
            }
        }
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch context.biometryType {
        case .none:
            return .pin
        case .faceID:
            return .faceId
        case .touchID:
            return .touchId
        @unknown default:
            return .pin
        }
    }
    
    
    enum BiometricType: String {
        case pin
        case touchId
        case faceId
    }
}


// MARK: - CAAnimationDelegate
extension AppLocker: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        clearView()
    }
}

// MARK: - Present
public extension AppLocker {
    // Present AppLocker
    class func present(with mode: ALMode, and config: ALOptions? = nil, over viewController: UIViewController? = nil) {
        let vc = viewController ?? UIApplication.shared.keyWindow?.rootViewController
        guard let root = vc,
            
            let locker = Bundle(for: self.classForCoder()).loadNibNamed(ALConstants.nibName, owner: self, options: nil)?.first as? AppLocker else {
                return
        }
        locker.messageLabel.text = config?.title ?? ""
        locker.submessageLabel.text = config?.subtitle ?? ""
        locker.view.backgroundColor = config?.color ?? .white
        locker.mode = mode
        locker.onSuccessfulDismiss = config?.onSuccessfulDismiss
        locker.onFailedAttempt = config?.onFailedAttempt
        
        if config?.isSensorsEnabled ?? false {
            locker.checkSensors()
        }
        
        if let image = config?.image {
            locker.photoImageView.image = image
        } else {
            locker.photoImageView.isHidden = true
        }
        root.navigationController?.pushViewController(locker, animated: true)
//        root.present(locker, animated: true, completion: nil)
    }
    
    class func rootViewController(with mode: ALMode, and config: ALOptions? = nil, window: UIWindow?) {
//        let vc = viewController ?? UIApplication.shared.keyWindow?.rootViewController
        guard //let root = vc,
            
            let locker = Bundle(for: self.classForCoder()).loadNibNamed(ALConstants.nibName, owner: self, options: nil)?.first as? AppLocker  else {
                return
        }
        locker.messageLabel.text = config?.title ?? ""
        locker.submessageLabel.text = config?.subtitle ?? ""
        locker.view.backgroundColor = config?.color ?? .white
        locker.mode = mode
        locker.onSuccessfulDismiss = config?.onSuccessfulDismiss
        locker.onFailedAttempt = config?.onFailedAttempt
        
        if config?.isSensorsEnabled ?? false {
            locker.checkSensors()
        }
        
        if let image = config?.image {
            locker.photoImageView.image = image
        } else {
            locker.photoImageView.isHidden = true
        }
        window?.rootViewController = locker //MainTabBarViewController()
        window?.makeKeyAndVisible()
//        root.navigationController?.pushViewController(locker, animated: true)
    }
}
