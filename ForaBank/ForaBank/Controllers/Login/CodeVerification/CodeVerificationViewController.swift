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
    var count = 60  // 60sec if you want
    var resendTimer = Timer()
    
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
        smsCodeView.callBacktext = { str in self.sendSmsCode(code: str) }
//        updateTimer()
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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
            "appId": "IOS",
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
                    "operationSystem": "IOS",
                    "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
                    "pushFcmToken": FCMToken.fcmToken
                ] as [String : AnyObject]
                
                NetworkManager<DoRegistrationDecodebleModel>.addRequest(.doRegistration, [:], body) { [weak self] model, error in
                    if error != nil {
                        guard let error = error else { return }
                        self?.showAlert(with: "Ошибка", and: error)
                    }
                    guard let model = model else { return }
                    
                    if model.statusCode == 0 {
                        guard let serverDeviceGUID = model.data else { return }
                        UserDefaults.standard.set(serverDeviceGUID, forKey: "serverDeviceGUID")
                        
                        
                        //TODO: go to app
                        DispatchQueue.main.async { [weak self] in
                            self?.pin(.create)
                        }
                        
                    }
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
            print(count)
            if count < 10 {
                timerLabel.text = "00:0\(count)"
            } else {
                timerLabel.text = "00:\(count)"
            }
        }
        else {
            resendTimer.invalidate()
            print("call your api")
            repeatCodeButton.isHidden = false
            timerLabel.isHidden = true
            
            // if you want to reset the time make count = 60 and resendTime.fire()
        }
    }
    
    @objc func repeatCodeButtonTapped() {
        NetworkManager<GetCodeDecodebleModel>.addRequest(.getCode, [:], [:]) { model, error in
            if error != nil {
                guard let error = error else { return }
                self.showAlert(with: "Ошибка", and: error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    DispatchQueue.main.async {
                        self.count = 60
                        self.resendTimer.fire()
                        self.repeatCodeButton.isHidden = true
                        self.timerLabel.isHidden = false
                    }
                } else {
                    guard let error = model?.errorMessage else { return }
                    self.showAlert(with: "Ошибка", and: error)
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
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
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
