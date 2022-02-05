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
    // Key for saving pincode to keychain
    static let kPincode = "pincode"
    // Your message when sensors must be shown
    static let kLocalizedReason = "Unlock with sensor"
    // Duration of indicator filling
    static let duration = 0.3
    static let maxPinLength = 4
    
    enum button: Int {
        case delete = 1000
        case cancel = 1001
    }
}

// Cancel dismiss will send mode as nil
public typealias onSuccessfulDismissCallback = (_ mode: ALMode?, _ code: String?) -> ()

public typealias onFailedAttemptCallback = (_ mode: ALMode) -> ()

// The structure used to display the controller
public struct ALOptions {
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public var color: UIColor?
    public var isSensorsEnabled: Bool?
    public var onSuccessfulDismiss: onSuccessfulDismissCallback?
    public var onFailedAttempt: onFailedAttemptCallback?
    public init() { }
}

// Modes for AppLocker
public enum ALMode {
    case validate
    case login
    case change
    case deactive
    case create
}

public class AppLocker: UIViewController {
    // MARK: - Top view
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
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.layer.cornerRadius = deleteButton.layer.bounds.height / 2
        }
    }
    
    weak var lockerDelegate: LockerViewControllerDelegate?

    static let valet = Valet.valet(
        with: Identifier(nonEmpty: "Druidia")!,
        accessibility: .whenUnlockedThisDeviceOnly)
    // MARK: - Pincode
    var onSuccessfulDismiss: onSuccessfulDismissCallback?
    var onFailedAttempt: onFailedAttemptCallback?
    var context = LAContext()
    var pin = "" // Entered pincode
    var reservedPin = "" // Reserve pincode for confirm
    var isFirstCreationStep = true
    var mode: ALMode = .validate
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
    
    //MARK: - Lifecycle
    
    private var isSensorsDisabledForEarlyOpenedAppLocker = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        navigationController?.isNavigationBarHidden = true
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //FIXME: this is hotfix for the DBSNEW-2851 issue. Should be fixed in the refactoring process
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            
            let isSensorsEnabled = UserDefaults().object(forKey: "isSensorsEnabled") as? Bool
            if isSensorsEnabled ?? false {
                self?.checkSensors()
            }
        }
    }
    
    private func setupUI() {
        switch mode {
        case .create:
            cancelButton.isHidden = true
            submessageLabel.text = "Придумайте код из 4х цифр"
        case .change:
            cancelButton.isHidden = true
            submessageLabel.text = "Введите код"
        case .deactive:
            cancelButton.isHidden = true
            submessageLabel.text = "Введите код"
        case .validate:
            submessageLabel.text = "Введите код"
            cancelButton.isHidden = false
            isFirstCreationStep = false
        case .login:
            submessageLabel.text = "Введите код"
            cancelButton.isHidden = false
            isFirstCreationStep = false
        }
    }
    
    // Precreate settings for change mode
    private func precreateSettings() {
        mode = .create
        clearView()
    }
    
    // Fill or cancel fill for indicators
    private func drawing(isNeedClear: Bool, tag: Int? = nil) {
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
                case .login:
                    loginModeAction()
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
    
    private func loginModeAction() {
        login(with: pin, type: .pin) { error in
            self.clearView()
            if let error = error {
                print(error)
            } else {
                self.lockerDelegate?.goToTabBar()
            }
        }
    }
    
    private func validateModeAction() {
        login(with: pin, type: .pin) { error in
            self.clearView()
            if let error = error {
                print(error)
            } else {
                // свернуть и включить таймер
                DispatchQueue.main.async {
                    let realm = try? Realm()
                    try? realm?.write {
                        let counter = realm?.objects(GetSessionTimeout.self)
                        counter?.first?.mustCheckTimeOut = true
                        realm?.add(counter!)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func removePin() {
        try? AppLocker.valet.removeObject(forKey: ALConstants.kPincode)
        self.onSuccessfulDismiss?(self.mode, nil)
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
                lockerDelegate?.goToFaceId(pin: pin)
            default:
                break
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
        DispatchQueue.main.async {
            self.pin = ""
            self.pinIndicators.forEach { view in
                view.isNeedClear = false
                UIView.animate(withDuration: ALConstants.duration, animations: {
                    view.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
                })
            }
        }
    }
    
    
    // MARK: - Touch ID / Face ID
    func checkSensors() {
        
        guard mode == .login || mode == .validate else {
            return
        }
        
        guard let pin = try? AppLocker.valet.string(forKey: ALConstants.kPincode) else {
            return
        }
        
        // Get a fresh context for each login. If you use the same context on multiple attempts
        //  (by commenting out the next line), then a previously successful authentication
        //  causes the next policy evaluation to succeed without testing biometry again.
        //  That's usually not what you want.
        // see demo project at:
        // https://developer.apple.com/documentation/localauthentication/logging_a_user_into_your_app_with_face_id_or_touch_id
        
        context = LAContext()
        
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        
        var err: NSError? = nil
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy, error: &err) else {return}
        let biometricType = biometricType(with: context.biometryType)
        // The user is able to use his/her Touch ID / Face ID 👍
        context.evaluatePolicy(policy, localizedReason: ALConstants.kLocalizedReason, reply: {  success, error in
            if success {
                self.login(with: pin, type: biometricType) { error in
                    if let error = error {
                        print(error)
                        self.showAlert(with: "Ошибка", and: error)
                    } else {
                        if self.mode == .validate {
                            DispatchQueue.main.async {
                                let realm = try? Realm()
                                try? realm?.write {
                                    let counter = realm?.objects(GetSessionTimeout.self)
                                    counter?.first?.mustCheckTimeOut = true
                                    realm?.add(counter!)
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else if self.mode == .login {
                            DispatchQueue.main.async {
                                self.lockerDelegate?.goToTabBar()
                            }
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
        default:
            drawing(isNeedClear: false, tag: sender.tag)
        }
    }
    
    private func cleanAllData() {
        UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
        //TODO: - Написать очистку данных после выхода из приложения
        ClearRealm.clear()
        AppDelegate.shared.isAuth = false
    }
    
    func exit() {
        clearView()
        
        //TODO: Подменить root Controller убрав present
//        UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
//        let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
//        navVC.modalPresentationStyle = .fullScreen
//        self.present(navVC, animated: true, completion: nil)
        
        NetworkManager<LogoutDecodableModel>.addRequest(.logout, [:], [:]) { _,_  in
            DispatchQueue.main.async {
                self.cleanAllData()
                Model.shared.action.send(ModelAction.LoggedOut())
                let mySceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate

                let appNavigation = UINavigationController()
                mySceneDelegate?.appNavigationController = appNavigation
                let router = Router(navigationController: appNavigation)
                mySceneDelegate?.appRouter = router
                mySceneDelegate?.appCoordinator = MainCoordinator(router: router)
                
                mySceneDelegate?.window?.rootViewController = mySceneDelegate?.appCoordinator.toPresentable()
                mySceneDelegate?.window?.makeKeyAndVisible()
                mySceneDelegate?.appCoordinator.start()
            }
        }
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
                
                let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
                
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
                
                NetworkManager<LoginDoCodableModel>.addRequest(.login, [:], data) { model, error in
                    if error != nil {
                        guard let error = error else { return }
                        completion(error)
                    } else {
                        guard let statusCode = model?.statusCode else { return }
                        if statusCode == 0 {
                            
                            //TODO: remove after refactoring
                            Model.shared.action.send(ModelAction.LoggedIn())
                            
                            let bodyRegisterPush = [
                                "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                                "pushFcmToken": Messaging.messaging().fcmToken as String?
                            ] as [String : AnyObject]
                            NetworkManager<RegisterPushDeviceDecodebleModel>.addRequest(.registerPushDeviceForUser, [:], bodyRegisterPush) { modelPush, error in
                                if error != nil {
                                    guard let error = error else { return }
                                    self.showAlert(with: "Ошибка", and: error)
                                }
                                guard let mPush = modelPush else { return }
                                if mPush.statusCode == 0 {
                                    DispatchQueue.main.async {
                                        AppDelegate.shared.isAuth = true
                                        
                                        // Обновление времени старта
                                        let realm = try? Realm()
                                        let timeOutObjects = self.returnRealmModel()
                                        
                                        // Сохраняем в REALM
                                        do {
                                            let b = realm?.objects(GetSessionTimeout.self)
                                            realm?.beginWrite()
                                            realm?.delete(b!)
                                            realm?.add(timeOutObjects)
                                            try realm?.commitWrite()
                                            print(realm?.configuration.fileURL?.absoluteString ?? "")
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        
                                        
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
        
        let updatingTimeObject = GetSessionTimeout()
        
        let userIsRegister = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
        if userIsRegister == true {
            // Сохраняем текущее время
        let updatingTimeObject = GetSessionTimeout()
        
            updatingTimeObject.currentTimeStamp = Date().localDate()
            updatingTimeObject.lastActionTimestamp = Date().localDate()
            updatingTimeObject.renewSessionTimeStamp = Date().localDate()
            updatingTimeObject.mustCheckTimeOut = true
            
        }
        return updatingTimeObject
    }
    
    func biometricType(with type: LABiometryType) -> BiometricType {

        switch type {
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
