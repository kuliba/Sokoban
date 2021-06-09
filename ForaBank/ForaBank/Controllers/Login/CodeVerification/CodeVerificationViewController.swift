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
        ]
        
        NetworkManager<VerifyCodeDecodebleModel>.addRequest(.verifyCode, [:], body) { [weak self] model, error in
            if error != nil {
                guard let error = error else { return }
                self?.showAlert(with: "Ошибка", and: error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                
                let body = ["model": UIDevice().model,
                            "operationSystem": "iOS",
                            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                            "pushFcmToken": Messaging.messaging().fcmToken! as String]
                
                NetworkManager<DoRegistrationDecodebleModel>.addRequest(.doRegistration, [:], body) { [weak self] model, error in
                    if error != nil {
                        guard let error = error else { return }
                        self?.showAlert(with: "Ошибка", and: error)
                    }
                    guard let model = model else { return }
                    
                    if model.statusCode == 0 {
                        guard let serverDeviceGUID = model.data else { return }
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.pin(.create)
                        }
                        
                        let data = [
                            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                            "pushFcmToken": Messaging.messaging().fcmToken! as String,
                            "serverDeviceGUID" : serverDeviceGUID,

                        ]
//
//                        NetworkManager<SetDeviceSettingDecodbleModel>.addRequest(.setDeviceSetting, [:], data) { model, error in
//
//                            if error != nil {
//                                // TODO: Alert
//                                print("DEBUG: ", error)
//                            }
//                            guard let model = model else { return }
//
//                            if model.statusCode == 0 {
                                
                                
//                            }
//                        }
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
        AppLocker.present(with: mode, and: options, over: self)
    }

}
