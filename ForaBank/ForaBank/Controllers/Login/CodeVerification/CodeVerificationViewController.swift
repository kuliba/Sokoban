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
    
    weak var delegate: CodeVerificationDelegate?

    var viewModel: CodeVerificationViewModel
    var count = 60  // 60sec if you want
    var resendTimer = Timer()
    
//    var cardNumber: String?
    
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
            // Для тесторов AppStore
            if str == "123456" {
                DispatchQueue.main.async {
                    let vc = MainTabBarViewController()
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            } else {
                self.sendSmsCode(code: str)
               }
        }

        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
        
    init(model: CodeVerificationViewModel) {
        self.viewModel = model
//        let cardNumber = UserDefaults.standard.object(forKey: "phone") as? String
//        if cardNumber != nil {
//            self.viewModel.phone = cardNumber ?? ""
//        }
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
        
        // Отправляем код из СМС
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
                            
                let body = [
                    "cryptoVersion": "1.0",
                    "model": encript(string: UIDevice().model),
                    "operationSystem": encript(string: "IOS"),
                    "pushDeviceId":encript(string: UIDevice.current.identifierForVendor!.uuidString),
                    "pushFcmToken":encript(string: Messaging.messaging().fcmToken as String? ?? "")
                ] as [String : AnyObject]
                
                // Если код СМС правильный, регистрируемся
                NetworkManager<DoRegistrationDecodebleModel>.addRequest(.doRegistration, [:], body) { [weak self] model, error in
                    if error != nil {
                        guard let error = error else { return }
                        self?.showAlert(with: "Ошибка", and: error)
                    }
                    guard let model = model else { return }
                    
                    if model.statusCode == 0 {
                        guard let serverDeviceGUID = model.data else { return }
                        
                        let decodedData = Data(base64Encoded: (serverDeviceGUID))
                        var decryptPhone: String?
                        do {
                            guard let key = KeyFromServer.secretKey else {
                                return
                            }
                            let aes = try AES(keyString: key)
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
                            // Переход на создание пинкода
                            let del = self?.delegate
                            del?.goToCreatePinVC()
//                            self?.pin(.create)
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

    }
    
    //MARK: - Actions
    @objc func updateTimer() {
        if(count > 0) {
            count = count - 1
            if count < 10 {
                timerLabel.text = "00:0\(count)"
            } else {
                timerLabel.text = "00:\(count)"
            }
        }
        else {
            resendTimer.invalidate()
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
    
}
