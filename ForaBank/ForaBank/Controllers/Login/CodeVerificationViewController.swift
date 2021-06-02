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
    
    
    fileprivate func setupUI() {
        title = "Вход"
        subTitleLabel.numberOfLines = 2
        subTitleLabel.textAlignment = .center
        smsCodeView.Base.changeInputNum(num: 6)
        
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(smsCodeView)
        
        titleLabel.centerX(inView: view, topAnchor: view.topAnchor, paddingTop: 30)
        smsCodeView.centerX(inView: view, topAnchor: titleLabel.bottomAnchor, paddingTop: 28)
        smsCodeView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                           paddingLeft: 20, paddingRight: 20, height: 60)
        subTitleLabel.centerX(inView: view, topAnchor: smsCodeView.bottomAnchor, paddingTop: 20)
        
        
    }
    
    //MARK: - API
    //TODO: BUG: Можно ввести в поле больше символов чем есть полей
    func sendSmsCode(code: String) {
        print("DEBUG: " + #function + ": " + code)
        
    }

}
