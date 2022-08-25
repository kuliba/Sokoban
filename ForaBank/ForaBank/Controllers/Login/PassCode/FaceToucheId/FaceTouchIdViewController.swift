//
//  FaceTouchIdViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 20.07.2021.
//

import UIKit
import Firebase
import FirebaseMessaging
import LocalAuthentication
import Valet
import RealmSwift


class FaceTouchIdViewController: UIViewController {
    
    weak var delegate: FaceTouchIDCoordinatorDelegate?
    
    var sensor: String?
    var code: String?
    var type: BiometricType?
    private let context = LAContext()
    
    lazy var image = UIImageView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
    var circleView = UIView()
    lazy var subTitleLabel = UILabel(text: "")
    lazy var skipButton: UIButton = {
        let button = UIButton(title: "Пропустить", titleColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    lazy var useButton = UIButton(title: "Использовать \(sensor ?? "")")
    
    enum BiometricType: String {
        case pin
        case touchId
        case faceId
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        type = biometricType()
        setupUI()
        useButton.addAction(for: .touchUpInside) { self.registerMyPinWith(with: true) }
        skipButton.addAction(for: .touchUpInside) { self.registerMyPinWith(with: false) }
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none:
            return .pin
        case .faceID:
            image.image = UIImage(imageLiteralResourceName: "faceId")
            sensor = "Face Id"
            return .faceId
        case .touchID:
            image.image = UIImage(imageLiteralResourceName: "touchId")
            sensor = "отпечаток"
            return .touchId
        @unknown default:
            return .pin
        }
    }
    
    func setupUI() {
        view.addSubview(subTitleLabel)
        subTitleLabel.numberOfLines = 2
        subTitleLabel.textAlignment = .center
        subTitleLabel.text = "Вместо пароля вы можете использовать \(sensor ?? "") для входа"
        subTitleLabel.textColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1)
        subTitleLabel.backgroundColor = .clear
        subTitleLabel.font = subTitleLabel.font.withSize(16)
        
        view.backgroundColor = .white
        view.addSubview(circleView)
        
        circleView.addSubview(image)
        view.addSubview(useButton)
        view.addSubview(skipButton)
        
        subTitleLabel.anchor(left: view.leftAnchor , right: view.rightAnchor, paddingLeft: 41, paddingRight: 41, width: 170, height: 170)
        subTitleLabel.centerX(inView: view, topAnchor: image.bottomAnchor,
                              paddingTop: 29)
        
        let circle = UIView()
        view.addSubview(circle)
        
        circle.centerX(inView: view)
        circle.addSubview(image)
        image.center(inView: circle)
        
        image.backgroundColor = .clear
        
        circle.anchor(top: view.topAnchor, paddingTop: 79, width: 170, height: 170)
        circle.layer.cornerRadius = 170/2
        circle.clipsToBounds = true
        
        circle.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        
        useButton.centerX(inView: view)
        useButton.anchor(bottom: skipButton.topAnchor, paddingTop: -20)
        useButton.anchor(left: view.leftAnchor, right: view.rightAnchor,
                         paddingLeft: 20, paddingRight: 20, height: 44)
        useButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        skipButton.centerX(inView: view, topAnchor: view.bottomAnchor,
                           paddingTop: -100)
        skipButton.anchor(left: view.leftAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingRight: 20, height: 44)
    }
    
    // MARK: - Helpers
    
    func encript(string: String?) -> String {
        do {
            guard let key = KeyFromServer.secretKey else { return "" }
            let aes = try AES(keyString: key)
            let stringToEncrypt: String = "\(string ?? "")"
            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            let _: String = try aes.decrypt(encryptedData)
            return encryptedData.base64EncodedString()
        } catch {
            return ""
        }
    }
    
    // MARK: - API
    
    func registerMyPinWith(with biometric: Bool) {
        showActivity()
        guard let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID") as? String else { return }
        UserDefaults().set(biometric, forKey: "isSensorsEnabled")
        
        let data = [
            "cryptoVersion": "1.0",
            "pushDeviceId": encript(string: UIDevice.current.identifierForVendor?.uuidString),
            "pushFcmToken": encript(string: Messaging.messaging().fcmToken as String?),
            "serverDeviceGUID" : encript(string: serverDeviceGUID),
            "settings": [
                ["type" : encript(string: "pin"),
                 "isActive": true,
                 "value": encript(string:code?.sha256())],
                ["type" : encript(string: "touchId"),
                 "isActive": biometric ? type == .touchId : false,
                 "value": encript(string:code?.sha256())],
                ["type" : encript(string: "faceId"),
                 "isActive": biometric ? type == .faceId : false ,
                 "value": encript(string:code?.sha256())]
            ] ] as [String : AnyObject]
        
        NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, [:], data) { model, error in
            
            if error != nil {
                guard let error = error else { return }
                self.dismissActivity()
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    UserDefaults.standard.set(true, forKey: "UserIsRegister")
                    DispatchQueue.main.async {
                        /*
                        AppDelegate.shared.getCSRF { errorMessage in
                            if errorMessage == nil {
                                self.login(with: self.code ?? "", type: .pin) { error in
                                    DispatchQueue.main.async {
                                        self.dismissActivity()
                                        if error != nil {
                                        } else {
                                            AppDelegate.shared.isAuth = true
                                            // Обновление времени старта после ввода нового пина при авторизации
                                            let realm = try? Realm()
                                            let timeOutObjects = returnRealmModel()

                                            /// Сохраняем в REALM
                                            do {
                                                let b = realm?.objects(GetSessionTimeout.self)
                                                realm?.beginWrite()
                                                realm?.delete(b!)
                                                realm?.add(timeOutObjects)
                                                try realm?.commitWrite()
                                            } catch {
                                                
                                            }
                                            self.dismissActivity()
                                            self.delegate?.goToTabBar()
                                        }
                                    }
                                }
                            } else {
                                self.dismissActivity()
                            }
                        }
                         */
                    }
                } else {
                    self.dismissActivity()
                }
            }
        }
    }
    
    func login(with code: String, type: BiometricType, completion: @escaping (_ error: String?) ->() ) {
        showActivity()
        
        let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID") as? String
        let data = [
            "appId": encript(string:"IOS"),
            "cryptoVersion": "1.0",
            "pushDeviceId": encript(string: UIDevice.current.identifierForVendor?.uuidString),
            "pushFcmToken": encript(string: Messaging.messaging().fcmToken),
            "serverDeviceGUID" : encript(string: serverDeviceGUID),
            "loginValue": encript(string: code.sha256()),
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
                    NetworkManager<RegisterPushDeviceDecodebleModel>.addRequest(.registerPushDeviceForUser, [:], bodyRegisterPush) { model, error in
                        if error != nil {
                            guard let error = error else { return }
                            self.showAlert(with: "Ошибка", and: error)
                        }
                        guard let model = model else { return }
                        if model.statusCode == 0 {
                            completion(nil)
                            
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
