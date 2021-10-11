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
import Firebase
import FirebaseMessaging
import CommonCrypto
import Security
import RealmSwift

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
    private var pin = "" // Entered pincode
    private var reservedPin = "" // Reserve pincode for confirm
    private var isFirstCreationStep = true
    private var savedPin: String? {
        get {
            return try? AppLocker.valet.string(forKey: ALConstants.kPincode)
        }
        set {
            guard let newValue = newValue else { return }
            try? AppLocker.valet.setString(newValue, forKey: ALConstants.kPincode)
        }
    }
    private var entryCount = 5
    
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
            case .change:
                cancelButton.isHidden = true
                submessageLabel.text = "Введите код" // Your submessage for change mode
            case .deactive:
                cancelButton.isHidden = true
                submessageLabel.text = "Введите код" // Your submessage for deactive mode
            case .validate:
                submessageLabel.text = "Введите код" // Your submessage for validate mode
                cancelButton.isHidden = false
                isFirstCreationStep = false
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
        //        if pin == savedPin {
        //            guard let pin = savedPin else { return }
        login(with: pin, type: .pin) { error in
            if let error = error {
                print(error)
            } else {
                self.onSuccessfulDismiss?(self.mode)
            }
        }
        //        } else {
        //            onFailedAttempt?(mode)
        //            incorrectPinAnimation()
        //        }
    }
    
    private func removePin() {
        try? AppLocker.valet.removeObject(forKey: ALConstants.kPincode)
        self.onSuccessfulDismiss?(self.mode)
    }
    
    private func confirmPin() {
        if pin == reservedPin {
            pinIndicators.forEach { pinIndicator in
                pinIndicator.layer.cornerRadius = 6
                pinIndicator.backgroundColor = UIColor(red: 0.133, green: 0.757, blue: 0.514, alpha: 1)
            }
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
            view.backgroundColor = UIColor(red: 0.89, green: 0.004, blue: 0.106, alpha: 1)
            
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
            exit()
            //        self.onSuccessfulDismiss?(nil)
            
        default:
            drawing(isNeedClear: false, tag: sender.tag)
        }
    }
    
    func exit() {
        clearView()
        //            dismiss(animated: true) {
        
        //TODO: Подменить root Controller убрав present
        UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
        let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
        
    }
    
}

extension AppLocker {
    
    
    //MARK: - API
    func registerMyPin(with code: String, completion: @escaping (_ error: String?) ->() ) {
        self.dismissActivity()
        let vc = FaceTouchIdViewController()
        vc.code = code
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func login(with code: String, type: BiometricType, completion: @escaping (_ error: String?) ->() ) {
        showActivity()
        DispatchQueue.main.async {
            AppDelegate.shared.getCSRF { error in
                if error != nil {
                    print("DEBUG: Error getCSRF: ", error!)
                }
                
                
                var serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
                
                func encript(string: String) -> String?{
                    do {
                        let aes = try AES(keyString: KeyFromServer.secretKey ?? Data())
                        
                        let stringToEncrypt: String = "\(string)"
                        
                        print("String to encrypt:\t\t\t\(stringToEncrypt)")
                        
                        let encryptedData: Data = try aes.encrypt(stringToEncrypt)
                        print("String encrypted (base64):\t\(encryptedData.base64EncodedString())")
                        
                        let decryptedData: String = try aes.decrypt(encryptedData)
                        print("String decrypted:\t\t\t\(decryptedData)")
                        return encryptedData.base64EncodedString()
                    } catch {
                        print("Something went wrong: \(error)")
                        return nil
                    }
                }
                
                let data = [
                    "appId": encript(string:"IOS" ),
                    "cryptoVersion": "1.0",
                    "pushDeviceId": encript(string: UIDevice.current.identifierForVendor!.uuidString),
                    "pushFcmToken": encript(string: Messaging.messaging().fcmToken as String? ?? ""),
                    "serverDeviceGUID" : encript(string: serverDeviceGUID as! String),
                    "loginValue": encript(string: code.sha256() ),
                    "type": encript(string: type.rawValue)
                ] as [String : AnyObject]
                //        print(data)
                print("DEBUG: Start login with body: ", data)
                NetworkManager<LoginDoCodableModel>.addRequest(.login, [:], data) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            
                            let bodyRegisterPush = [
                                "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                                "pushFcmToken": Messaging.messaging().fcmToken as String?
                            ] as [String : AnyObject]
                            print("DEBUG: Start registerPushDeviceForUser with body: ", bodyRegisterPush)
                            NetworkManager<RegisterPushDeviceDecodebleModel>.addRequest(.registerPushDeviceForUser, [:], bodyRegisterPush) { modelPush, error in
                                if error != nil {
                                    guard let error = error else { return }
                                    self.showAlert(with: "Ошибка", and: error)
                                }
                                guard let mPush = modelPush else { return }
                                if mPush.statusCode == 0 {
                                    print("DEBUG: You are LOGGIN!!!")
                                    DispatchQueue.main.async {
                                        AppDelegate.shared.isAuth = true
                                        
                                        // Обновление времени старта
                                        let realm = try? Realm()
                                        let timeOutObjects = self.returnRealmModel()
                                        
                                        /// Сохраняем в REALM
                                        do {
                                            let b = realm?.objects(GetSessionTimeout.self)
                                            realm?.beginWrite()
                                            realm?.delete(b!)
                                            realm?.add(timeOutObjects)
                                            try realm?.commitWrite()
                                            
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        //
                                        
                                    }
                                    self.dismissActivity()
                                    completion(nil)
                                }
                            }
                        } else if model?.statusCode == 102 {
                            DispatchQueue.main.async {
                                self.dismissActivity()
                                self.onFailedAttempt?(self.mode)
                                self.incorrectPinAnimation()
                                if let m = model?.data?.entryCount {
                                    self.entryCount = m
                                    self.showAlert(with: "Ошибка", and: "\(model?.errorMessage ?? "")\n Количество попыток \(self.entryCount)")
                                }
                            }
                        } else if model?.statusCode == 101 {
                            DispatchQueue.main.async {
                                self.dismissActivity()
                                if (model?.data?.entryCountError) != nil {
                                    self.exit()
                                }
                            }
                        } else {
                            guard let error = model?.errorMessage else { return }
                            completion(error)
                        }
                    }
                }
            }
        }
    }
    
    func returnRealmModel() -> GetSessionTimeout {
        let realm = try? Realm()
        guard let timeObject = realm?.objects(GetSessionTimeout.self).first else {return GetSessionTimeout()}
        let lastActionTimestamp = timeObject.lastActionTimestamp
        let maxTimeOut = timeObject.maxTimeOut
        let mustCheckTimeOut = timeObject.mustCheckTimeOut
        
        // Сохраняем текущее время
        let updatingTimeObject = GetSessionTimeout()
        
        updatingTimeObject.currentTimeStamp = Date().localDate()
        updatingTimeObject.lastActionTimestamp = Date().localDate()
        updatingTimeObject.renewSessionTimeStamp = Date().localDate()
        updatingTimeObject.mustCheckTimeOut = true
        
        return updatingTimeObject
        
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
//        root.navigationController?.pushViewController(locker, animated: true)
        root.modalPresentationStyle = .fullScreen
          root.present(locker, animated: true, completion: nil)
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
