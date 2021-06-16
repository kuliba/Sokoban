//
//  ContactConfurmViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 30.05.2021.
//

import UIKit


//TODO: отрефакторить под сетевые запросы, вынести в отдельный файл
struct ConfurmViewControllerModel {
    var phone: String?
    var name: String
    var country: Country
    var numberTransction: String?
    var summTransction: String
    var taxTransction: String
    var currancyTransction: String
    
    
    init(country: Country, model: AnywayPaymentDecodableModel?, fullName: String? = nil) {
        
        var name = ""
        var surname = ""
        var secondName = ""
        var phone = ""
        var transctionNum = ""
        if let listInputs = model?.data?.listInputs {
            for item in listInputs {
                if item.id == "RECF" {
                    surname = item.content?.first ?? ""
                } else if item.id == "RECI" {
                    name = item.content?.first ?? ""
                } else if item.id == "RECO" {
                    secondName = item.content?.first ?? ""
                } else if item.id == "RECP" {
                    phone = item.content?.first ?? ""
                } else if item.id == "trnReference" {
                    transctionNum = item.content?.first ?? ""
                }
            }
        }
        if let fullName = fullName {
            self.name = fullName
        } else {
            self.name = surname + " " + name + " " + secondName
        }
        
        self.phone = phone
        self.summTransction = "\(model?.data?.amount ?? 0) ₽"
        self.taxTransction = "\(model?.data?.commission ?? 0) ₽"
        self.numberTransction = transctionNum
        self.currancyTransction = "Наличные"
        self.country = country
    }
    
}

class ContactConfurmViewController: UIViewController {
    
    var confurmVCModel: ConfurmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            isEditable: false))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: false))
    
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false))
    
    var countryField = ForaInput(
        viewModel: ForaInputModel(
            title: "Страна",
            image: #imageLiteral(resourceName: "map-pin"),
            isEditable: false))
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: #imageLiteral(resourceName: "hash"),
            isEditable: false))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: false))
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var currancyTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Способ выплаты",
            image: #imageLiteral(resourceName: "Frame 579"),
            isEditable: false))
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: #imageLiteral(resourceName: "message-square"),
            type: .smsCode))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    func setupData(with model: ConfurmViewControllerModel) {
        nameField.text =  model.name //"Колотилин Михаил Алексеевич"
        countryField.text = model.country.name ?? "" // "Армения"
        numberTransctionField.text = model.numberTransction ?? "" //"1235634790"
        summTransctionField.text = model.summTransction //"10 000.00 ₽ "
        taxTransctionField.text = model.taxTransction //"100.00 ₽ "
        currancyTransctionField.text = model.currancyTransction //"Наличные"
        
        if model.country.code == "AM" {
            numberTransctionField.isHidden = true
            phoneField.isHidden = false
            phoneField.text = model.phone ?? ""
            bankField.isHidden = false
            bankField.text = "АйДиБанк"
            bankField.imageView.image = #imageLiteral(resourceName: "IdBank")
            let customViewItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "MigAvatar")))
            self.navigationItem.rightBarButtonItem = customViewItem
        } else {
            phoneField.isHidden = true
            bankField.isHidden = true
            numberTransctionField.isHidden = false
            let customViewItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "Vector")))
            self.navigationItem.rightBarButtonItem = customViewItem
        }
        
    }
    
    fileprivate func setupUI() {
        title = "Подтвердите реквизиты"
        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.003921568627, blue: 0.1058823529, alpha: 1)
        button.layer.cornerRadius = 22
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        
        
        let stackView = UIStackView(arrangedSubviews: [phoneField, nameField, bankField, countryField, numberTransctionField, summTransctionField, taxTransctionField, currancyTransctionField, smsCodeField, button])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20).isActive = true
//        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    @objc func doneButtonTapped() {
        print(#function)
        
        guard let code = smsCodeField.textField.text else { return }
        let body = ["verificationCode": code] as [String: AnyObject]
        showActivity()
        NetworkManager<AnywayPaymentMakeDecodableModel>.addRequest(.anywayPaymentMake, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success payment")
                self.dismissActivity()
                DispatchQueue.main.async {
                    self.showAlert(with: "Поздравляю", and: "Перевод совершен успешно") {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
        
    }
    

}

