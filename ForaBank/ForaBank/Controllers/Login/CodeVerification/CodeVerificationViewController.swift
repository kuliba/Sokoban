//
//  CodeVerificationViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit

class CodeVerificationViewController: UIViewController {
    
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
    
    //MARK: - API
    //TODO: BUG: Можно ввести в поле больше символов чем есть полей
    func sendSmsCode(code: String) {
        print("DEBUG: " + #function + ": " + code)
        pin(.create)
//        pin(.change)
//        pin(.deactive)
//        pin(.validate)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pin(_ mode: ALMode) {
        
        var options = ALOptions()
        
//        options.image = UIImage(named: "face")!
//        options.title = "Михаил Колотилин"
        options.isSensorsEnabled = true
        options.color = .white
        options.onSuccessfulDismiss = { (mode: ALMode?) in
            if let mode = mode {
                print("Password \(String(describing: mode))d successfully")
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
