//
//  CodeVerificationViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit
import FirebaseMessaging

class CodeVerificationViewController: UIViewController {
    
    var phoneNumber: String?
    
    lazy var titleLabel = UILabel(text: "Введите код из сообщения",
                                           font: .boldSystemFont(ofSize: 18))
    lazy var smsCodeView: SmsCodeView = SmsCodeView()
    lazy var subTitleLabel = UILabel(text: "Код отправлен на +7 ... ... .. ..\nЗапросить повторно можно через")
    lazy var button = UIButton(title: "done")
    
    //MARK: - Viewlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        smsCodeView.callBacktext = { str in self.sendSmsCode(code: str) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
        
    init(phone: String) {
        phoneNumber = phone
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    //TODO: BUG: Можно ввести в поле больше символов чем есть полей
    func sendSmsCode(code: String) {
        print("DEBUG: " + #function + ": " + code)
        
        let body = [
            "appId": "iOS",
            "verificationCode": "\(code)"
        ] as [String : AnyObject]
        
        NetworkManager<VerifyCodeDecodebleModel>.addRequest(.verifyCode, [:], body) { [weak self] model, error in
            if error != nil {
                guard let error = error else { return }
                self?.showAlert(with: "Ошибка", and: error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                
                let body = [
                    "model": UIDevice().model,
                    "operationSystem": "iOS",
                    "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                    "pushFcmToken": Messaging.messaging().fcmToken! as String
                ] as [String : AnyObject]
                
                NetworkManager<DoRegistrationDecodebleModel>.addRequest(.doRegistration, [:], body) { [weak self] model, error in
                    if error != nil {
                        guard let error = error else { return }
                        self?.showAlert(with: "Ошибка", and: error)
                    }
                    guard let model = model else { return }
                    
                    if model.statusCode == 0 {
                        guard let serverDeviceGUID = model.data else { return }
                        // TODO сохранить serverDeviceGUID
                        
                        
                        // TODO: перенести в AppLoker
                        let data = [
                            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                            "pushFcmToken": Messaging.messaging().fcmToken! as String,
                            "serverDeviceGUID" : serverDeviceGUID,
                            "settings": [
                                    [
                                        "type" : "pin",
                                        "isActive": true,
                                        "value": "5555"
                                        ],
                                    [
                                        "type" : "touchId",
                                        "isActive": true,
                                        "value": "finger"
                                    ],
                                    [
                                        "type" : "faceId",
                                        "isActive": true,
                                        "value": "face"
                                    ]
                                ]
                        ] as [String : AnyObject]

                        NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, [:], data) { [weak self] model, error in
                            if error != nil {
                                guard let error = error else { return }
                                self?.showAlert(with: "Ошибка", and: error)
                            } else {
                                guard let statusCode = model?.statusCode else { return }
                                if statusCode == 0 {
                                    
                                    
                                    
                                    //TODO: go to app
//                                    DispatchQueue.main.async { [weak self] in
//                                        self?.pin(.create)
//                                    }
                                    
                                    
                                    
                                    let parameters = [
                                        "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                                        "pushFCMtoken": Messaging.messaging().fcmToken! as String,
                                        "model": UIDevice().model,
                                        "operationSystem": "IOS"
                                    ] as [String : AnyObject]
                            //        print("DEBUG: Parameters = ", parameters)
                                    
                                    NetworkManager<CSRFDecodableModel>.addRequest(.csrf, [:], parameters) { request, error in
                                        guard let token = request?.data?.token else { return }
                                        
                                        
                                        // TODO: пределать на сингл тон
                                        UserDefaults.standard.set(token, forKey: "sessionToken")
                                        
                                        let tok = UserDefaults.standard.object(forKey: "sessionToken")
                                        print("DEBUG: Token = ", tok)
                                        
                                        
                                        // TODO: перенести в AppLoker
                                        let data = [
                                            "appId": "iOS",
                                            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                                            "pushFcmToken": Messaging.messaging().fcmToken! as String,
                                            "serverDeviceGUID": serverDeviceGUID,
                                            "loginValue": "5555", // TODO: from success pin
                                            "type": "pin"
                                        ] as [String : AnyObject]
                                        NetworkManager<LoginDoCodableModel>.addRequest(.login, [:], data) { model, error in
                                            if error != nil {
                                                guard let error = error else { return }
                                                self?.showAlert(with: "Ошибка", and: error)
                                            } else {
                                                guard let statusCode = model?.statusCode else { return }
                                                if statusCode == 0 {
                                            
                                                    
                                                    //TODO: go to app
                                                    DispatchQueue.main.async { [weak self] in
                                                        self?.pin(.create)
                                                    }
                                                    
                                                    
                                                } else {
                                                    guard let error = model?.errorMessage else { return }
                                                    self?.showAlert(with: "Ошибка", and: error)
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
//                                    print("DEBUG: setDeviceSetting Succsess")
                                    
                                    
                                    
                                    
                                    
                                } else {
                                    guard let error = model?.errorMessage else { return }
                                    self?.showAlert(with: "Ошибка", and: error)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
//        pin(.change)
//        pin(.deactive)
//        pin(.validate)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pin(_ mode: ALMode) {
        
        var options = ALOptions()
        options.isSensorsEnabled = true
        options.color = .white
        options.onSuccessfulDismiss = { (mode: ALMode?) in
            if let mode = mode {
                print("Password \(String(describing: mode)) successfully")
                let vc = MainTabBarViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else {
                print("User Cancelled")
            }
        }
        options.onFailedAttempt = { (mode: ALMode?) in
            print("Failed to \(String(describing: mode))")
        }
        // LOGIN DO
        AppLocker.present(with: mode, and: options, over: self)
    }

}
