//
//  CodeVerificationViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit
import Firebase
import FirebaseMessaging


class CodeVerificationViewController: UIViewController {
    
//    var phoneNumber: String?
    var viewModel: CodeVerificationViewModel
    var count = 60  // 60sec if you want
    var resendTimer = Timer()
//    var verificationType: CodeVerificationViewModel.CodeVerificationType? = .register
    
    lazy var titleLabel = UILabel(text: "Введите код из сообщения",
                                  font: .boldSystemFont(ofSize: 18))
    lazy var smsCodeView: SmsCodeView = SmsCodeView()
    lazy var subTitleLabel = UILabel(text: "Код отправлен на +7 ... ... .. ..\nЗапросить повторно можно через")
    lazy var timerLabel = UILabel(text: "01:00", font: .systemFont(ofSize: 18), color: .black)
    lazy var repeatCodeButton: UIButton = {
        let button = UIButton(title: "Отправить повторно", titleColor: #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1), backgroundColor: #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1))
        button.setDimensions(height: 32, width: 180)
        button.addTarget(self, action: #selector(repeatCodeButtonTapped), for: .touchUpInside)
        return button
    }()

    
    //MARK: - Viewlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        navigationController?.view.backgroundColor = .white
        smsCodeView.callBacktext = { str in
            if str == "123456"{
                DispatchQueue.main.async { [weak self] in
//                    print("Password \(String(describing: mode)) successfully")
                    let vc = MainTabBarViewController()
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
//                    vc.modalPresentationStyle = .fullScreen
//                    self?.present(vc, animated: true)
                }
            }
            self.sendSmsCode(code: str)
            
        }
//        updateTimer()
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
        
    init(model: CodeVerificationViewModel) {
        self.viewModel = model
//        phoneNumber = phone
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func encript(string: String) -> String?{
        do {
            guard let key = KeyFromServer.secretKey else {
                return ""
            }
            let aes = try AES(keyString: key)

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
    
    //MARK: - API
    //TODO: BUG: Можно ввести в поле больше символов чем есть полей
    func sendSmsCode(code: String) {
        let body = [
            "verificationCode": "\(code)"
        ] as [String : AnyObject]
        
        print("DEBUG: Start verifyCode with body: ", body)
        NetworkManager<VerifyCodeDecodebleModel>.addRequest(.verifyCode, [:], body) { [weak self] model, error in
            if error != nil {
                guard let error = error else { return }
                self?.showAlert(with: "Ошибка", and: error)
            }
            
            func encript(string: String) -> String?{
                do {
                    guard let key = KeyFromServer.secretKey else {
                        return ""
                    }
                    let aes = try AES(keyString: key)

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
            
            guard let model = model else { return }
            if model.statusCode == 0 {
                
                print("DEBUG: messaging().fcmToken = ", Messaging.messaging().fcmToken)
                
                let body = [
                    "cryptoVersion": "1.0",
                    "model": encript(string: UIDevice().model),
                    "operationSystem": encript(string: "IOS"),
                    "pushDeviceId":encript(string: UIDevice.current.identifierForVendor!.uuidString),
                    "pushFcmToken":encript(string: Messaging.messaging().fcmToken as String? ?? "")
                ] as [String : AnyObject]
                
                print("DEBUG: Start doRegistration with body:", body)
                NetworkManager<DoRegistrationDecodebleModel>.addRequest(.doRegistration, [:], body) { [weak self] model, error in
                    if error != nil {
                        guard let error = error else { return }
                        self?.showAlert(with: "Ошибка", and: error)
                    }
                    guard let model = model else { return }
                    
                    if model.statusCode == 0 {
                        guard let serverDeviceGUID = model.data else { return }
                        let data = serverDeviceGUID.data(using: .utf8)
//                        var data1 = model?.data?.phone?.base64Decoded()
                        let decodedData = Data(base64Encoded: (serverDeviceGUID))
    //                    let decodedString = String(data: decodedData!, encoding: .utf8)!

    //                    func testEnc() {
    //
    ////                        let aesKey = password.padding(toLength: 32, withPad: "0", startingAt: 0)
    //
    //                        let aes = try? AES256(key: KeyFromServer.secretKey!, iv: AES256.randomIv())
    //
    //                        let decryptString = try? aes?.decrypt(data)
    //                        print(decryptString)
    //                    }
    //                    testEnc()
    //                    let str = model?.data?.phone?.data
                        var decryptPhone: String?
                        do {
                            guard let key = KeyFromServer.secretKey else {
                                return
                            }
                            let aes = try AES(keyString: key)
    //                        let decryptedString = try AES256(key: KeyFromServer.secretKey!, iv: AES256.randomIv()).decrypt(data)
    //                        print(decryptedString)
                            let decryptedData: String = try aes.decrypt(decodedData!)
                            print("String decrypted:\t\t\t\(decryptedData)")
                            decryptPhone = decryptedData
                        } catch {
                            print("Something went wrong: \(error)")
                        }
                        UserDefaults.standard.set(decryptPhone, forKey: "serverDeviceGUID")
                        
                        
                        //TODO: go to app
                        DispatchQueue.main.async { [weak self] in
                            self?.resendTimer.invalidate()
                            self?.pin(.create)
                        }
                        
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    print("Неверный код")
                    self?.smsCodeView.clearnText(error: "error")
                    self?.showAlert(with: model.errorMessage ?? "", and: "Осталось попыток : \(model.data?.verifyOTPCount ?? 0)")
                }
            }
        }
        
//        pin(.change)
//        pin(.deactive)
//        pin(.validate)

    }
    
    //MARK: - Actions
    @objc func updateTimer() {
        if(count > 0) {
            count = count - 1
//            print(count)
            if count < 10 {
                timerLabel.text = "00:0\(count)"
            } else {
                timerLabel.text = "00:\(count)"
            }
        }
        else {
            resendTimer.invalidate()
//            print("call your api")
            repeatCodeButton.isHidden = false
            timerLabel.isHidden = true
        }
    }
    
    @objc func repeatCodeButtonTapped() {
        viewModel.getCode { error in
            if error != nil {
                guard let error = error else { return }
                self.showAlert(with: "Ошибка", and: error)
            } else {
                DispatchQueue.main.async { [self] in
                    self.count = 60
                    self.resendTimer.fire()
                    self.updateTimer()
                    resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.self.updateTimer), userInfo: nil, repeats: true)
                    self.repeatCodeButton.isHidden = true
                    self.timerLabel.isHidden = false
                }
            }
        }
    }
    
    func pin(_ mode: ALMode) {
        
        var options = ALOptions()
        options.isSensorsEnabled = true
        options.color = .white
        options.onSuccessfulDismiss = { (mode: ALMode?) in
            if let mode = mode {
                DispatchQueue.main.async { [weak self] in
                    print("Password \(String(describing: mode)) successfully")
                    let vc = MainTabBarViewController()
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
//                    vc.modalPresentationStyle = .fullScreen
//                    self?.present(vc, animated: true)
                }
            } else {
                print("User Cancelled")
            }
        }
        options.onFailedAttempt = { (mode: ALMode?) in
            print("Failed to \(String(describing: mode))")
        }
        // LOGIN DO
       // AppLocker.present(with: mode, and: options, over: self)
    }

}
