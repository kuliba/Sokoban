//
//  SettingsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 21.07.2021.
//

import UIKit

class SettingsViewController: UIViewController {

    let imageView = UIImageView(image: UIImage(named: "ErrorIcon"))
    
    let titleLabel = UILabel(
        text: "Настройки",
        font: .boldSystemFont(ofSize: 18), color: .black)
    
    let subTitleLabel = UILabel(
        text: "Отображать копейки",
        font: .systemFont(ofSize: 14), color: .black)
    
    let currencySwitch = UISwitch()
    
    lazy var sbpButton: UIButton = {
        let button = UIButton(title: "Настройки СБП", titleColor: .black, backgroundColor: .lightGray)
        button.addTarget(self, action: #selector(sbpButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(title: "Выход")
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(currencySwitch)
        view.addSubview(sbpButton)
        view.addSubview(logoutButton)
        
        titleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .left
        
        imageView.setDimensions(height: 250, width: 250)
        imageView.layer.cornerRadius = 125
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.centerX(inView: view,
                          topAnchor: view.safeAreaLayoutGuide.topAnchor,
                          paddingTop: 22)
        
        titleLabel.anchor(left: view.leftAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingRight: 20)
        titleLabel.centerX(inView: view,
                           topAnchor: imageView.bottomAnchor, paddingTop: 44)
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20)
        
        currencySwitch.centerY(inView: subTitleLabel)
        currencySwitch.anchor(right: view.rightAnchor, paddingRight: 20)
        currencySwitch.addTarget(self, action: #selector(currSwitch), for: .valueChanged)
        
        sbpButton.anchor(top: currencySwitch.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 30, height: 44)
        
        logoutButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 30, paddingRight: 20, height: 44)
        
        addCloseButton_setting()
        
    }

    @objc func currSwitch() {
        if currencySwitch.isOn {
            UserDefaults.standard.setValue(2, forKey: "maximumFractionDigits")
        } else {
            UserDefaults.standard.setValue(0, forKey: "maximumFractionDigits")
        }
    }
    
    @objc func sbpButtonAction() {
        #if DEBUG
        self.showActivity()
        getFastPaymentContractList { [weak self] contractList, fail in
            self?.dismissActivity()
            if fail != nil {
                self?.showAlert(with: "Ошибка", and: fail!)
            } else {
                DispatchQueue.main.async {
                    let vc = MeToMeSettingViewController()
                    if contractList != nil {
                        vc.model = contractList
                    } else {
                        vc.model = []
                    }
                    vc.addCloseButton()
                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    self?.present(navVC, animated: true, completion: nil)
                }
            }
        }
        #endif
    }
    
    @objc func logout() {
        
        NetworkManager<LogoutDecodableModel>.addRequest(.logout, [:], [:]) { _,_  in
            DispatchQueue.main.async {
                self.cleanAllData()
                Model.shared.action.send(ModelAction.LoggedOut())
                let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
            }
            
        }
    }
    
    private func cleanAllData() {
        UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
//        AppDelegate.shared.isAuth = false
    }
    
    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                completion(nil, model.errorMessage)
            }
        }
    }
    
}

