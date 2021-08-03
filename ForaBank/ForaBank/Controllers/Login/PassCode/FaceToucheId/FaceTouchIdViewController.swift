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


class FaceTouchIdViewController: UIViewController {

    var sensor: String?
    var code: String?
    var face = false
    var touch = false
    private let context = LAContext()
    public var onSuccessfulDismiss: onSuccessfulDismissCallback?

    
    lazy var image = UIImageView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
     var circleView = UIView()
    lazy var subTitleLabel = UILabel(text: "")
    lazy var skipButton: UIButton = {
        let button = UIButton(title: "Пропустить", titleColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    lazy var useButton = UIButton(title: "Использовать \(sensor ?? "")")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        biometricType()
        setupUI()
        useButton.addTarget(self, action: #selector(registerMyPin), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipRegisterMyPin), for: .touchUpInside)

    }
    
    
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch context.biometryType {
        case .none:
            return .pin
        case .faceID:
            image.image = UIImage(imageLiteralResourceName: "faceId")
            sensor = "Face Id"
            face = true
            return .faceId
        case .touchID:
            image.image = UIImage(imageLiteralResourceName: "touchId")
            sensor = "отпечаток"
            touch = true
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
    
    
    @objc func registerMyPin() {
        showActivity()
        let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
        
        func encript(string: String) -> String?{
            do {
                let aes = try AES(keyString: KeyFromServer.secretKey!)

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
            "pushDeviceId": encript(string: UIDevice.current.identifierForVendor!.uuidString),
            "pushFcmToken": encript(string: Messaging.messaging().fcmToken as String? ?? ""),
            "serverDeviceGUID" : encript(string: serverDeviceGUID as! String),
            "settings": [ ["type" : encript(string:"pin"),
                           "isActive": true,
                           "value": encript(string:code?.sha256() ?? "")],
                          ["type" : encript(string:"touchId"),
                           "isActive": touch,
                           "value": encript(string:code ?? "")],
                          ["type" : encript(string:"faceId"),
                           "isActive": face ,
                           "value": encript(string:code ?? "")] ] ] as [String : AnyObject]
        
        print("DEBUG: Start setDeviceSetting with body: ", data)
        
        NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, [:], data) { model, error in
            self.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                print("DEBUG: setDeviceSetting" ,error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    UserDefaults.standard.set(true, forKey: "UserIsRegister")
                    DispatchQueue.main.async {
                        AppDelegate.shared.getCSRF { error in
                            if error != nil {
                                print("DEBUG: Error getCSRF: ", error!)
                            } else {
                                self.login(with: self.code ?? "", type: .pin) { error in
                                    if error != nil {
                                        print("DEBUG: Error getCSRF: ", error!)
                                    } else {
                                        self.dismissActivity()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    guard let error = model?.errorMessage else { return }
                    print("DEBUG: setDeviceSetting" ,error)
                }
            }
        }
    }
    @objc func skipRegisterMyPin() {
        showActivity()
        let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
        
        let data = [
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFcmToken": Messaging.messaging().fcmToken as String? ?? "",
            "serverDeviceGUID" : serverDeviceGUID ?? "",
            "settings": [ ["type" : "pin",
                           "isActive": true,
                           "value": code ?? ""],
                          ["type" : "touchId",
                           "isActive": false,
                           "value": code ?? ""],
                          ["type" : "faceId",
                           "isActive": false ,
                           "value": code ?? ""] ] ] as [String : AnyObject]
        
        print("DEBUG: Start setDeviceSetting with body: ", data)
        
        NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, [:], data) { model, error in
            self.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                print("DEBUG: setDeviceSetting" ,error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    UserDefaults.standard.set(true, forKey: "UserIsRegister")
                    DispatchQueue.main.async {
                        AppDelegate.shared.getCSRF { error in
                            if error != nil {
                                print("DEBUG: Error getCSRF: ", error!)
                            } else {
                                self.login(with: self.code ?? "", type: .pin) { error in
                                    if error != nil {
                                        print("DEBUG: Error getCSRF: ", error!)
                                    } else {
                                        self.dismissActivity()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    guard let error = model?.errorMessage else { return }
                    print("DEBUG: setDeviceSetting" ,error)
                }
            }
        }
    }
    
    
    func login(with code: String, type: BiometricType, completion: @escaping (_ error: String?) ->() ) {
        showActivity()
        let serverDeviceGUID = UserDefaults.standard.object(forKey: "serverDeviceGUID")
        let data = [
            "appId": "IOS",
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
            "pushFcmToken": Messaging.messaging().fcmToken as String?,
            "serverDeviceGUID": serverDeviceGUID,
            "loginValue": code,
            "type": type.rawValue
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
                    NetworkManager<RegisterPushDeviceDecodebleModel>.addRequest(.registerPushDeviceForUser, [:], bodyRegisterPush) { model, error in
                        if error != nil {
                            guard let error = error else { return }
                            self.showAlert(with: "Ошибка", and: error)
                        }
                        guard let model = model else { return }
                        if model.statusCode == 0 {
                            print("DEBUG: You are LOGGIN!!!")
                            self.dismissActivity()
                                    DispatchQueue.main.async { [weak self] in
                                        let vc = MainTabBarViewController()
                                        vc.modalPresentationStyle = .fullScreen
                                        self?.present(vc, animated: true)
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
    
    func setupUI() {
        

        subTitleLabel.numberOfLines = 2
        subTitleLabel.textAlignment = .center
        subTitleLabel.text = "Вместо пароля вы можете использовать \(sensor ?? "") для входа"
        subTitleLabel.textColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1)
        subTitleLabel.backgroundColor = .clear
        subTitleLabel.font = subTitleLabel.font.withSize(16)
        
        view.backgroundColor = .white
        view.addSubview(circleView)
        view.addSubview(subTitleLabel)
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


    
    
}
