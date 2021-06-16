//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ContactInputViewController: UIViewController {
    
    var selectedCardNumber = "" {
        didSet {
            self.isFirstStartPayment = false
            self.startContactPayment(with: selectedCardNumber) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }
    var isFirstStartPayment = true
    var country: Country? {
        didSet {
            self.configure(with: country)
        }
    }
    var foraSwitchView = ForaSwitchView()
    
    var surnameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Фамилия получателя",
            image: #imageLiteral(resourceName: "accountImage"),
//            needValidate: true,
            errorText: "Фамилия указана не верно"))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя получателя",
//            needValidate: true,
            errorText: "Имя указана не верно"))
    
    var secondNameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество получателя (если есть)"))
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone")))
    
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false,
            showChooseButton: true))
    
    var countryField = ForaInput(
        viewModel: ForaInputModel(
            title: "Страна",
            image: #imageLiteral(resourceName: "map-pin"),
            isEditable: false,
            showChooseButton: true))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            type: .amountOfTransfer))
    
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false))
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            
        }
        countryField.didChooseButtonTapped = { () in
            print("countryField didChooseButtonTapped")
            let vc = ChooseCountryTableViewController()
            vc.modalPresent = true
            vc.didChooseCountryTapped = { (country) in
                self.country = country
            }
            let navVc = UINavigationController(rootViewController: vc)
            self.present(navVc, animated: true, completion: nil)
        }
        bankField.didChooseButtonTapped = { () in
            print("bankField didChooseButtonTapped")
            
        }
        getCardList { error in
            self.dismissActivity()
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstStartPayment {
            self.startContactPayment(with: selectedCardNumber) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }

    fileprivate func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(doneButton)
        doneButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                          paddingRight: 20, height: 44)
                
        
        
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        
        
        let stackView = UIStackView(arrangedSubviews: [foraSwitchView, surnameField, nameField, secondNameField, phoneField, countryField, bankField, cardField ,summTransctionField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 20)
        
    }
    
    private func configure(with: Country?) {
        guard let country = country else { return }
        foraSwitchView.isHidden = country.code == "AM" ? false : true
        phoneField.isHidden = country.code == "AM" ? false : true
        bankField.isHidden = country.code == "AM" ? false : true
        surnameField.isHidden = country.code == "AM" ? true : false
        nameField.isHidden = country.code == "AM" ? true : false
        secondNameField.isHidden = country.code == "AM" ? true : false
        
        title = country.code == "AM"
            ? "Денежные переводы Миг"
            : "Денежные переводы Contact"
        
        let navImage = country.code == "AM" ? #imageLiteral(resourceName: "MigAvatar") : #imageLiteral(resourceName: "Vector")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
        guard let countryName = country.name else { return }
        countryField.textField.text = countryName
        countryField.text = countryName
    }
    
    @objc func doneButtonTapped() {
        guard let country = country else { return }
        if country.code == "AM" {
            let phone = phoneField.textField.text ?? ""
            let amount = summTransctionField.textField.text ?? ""
            
            endMigPayment(phone: phone, amount: amount) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        } else {
            let surname = surnameField.textField.text ?? ""
            let name = nameField.textField.text ?? ""
            let secondName = secondNameField.textField.text ?? ""
            let amount = summTransctionField.textField.text ?? ""
            
            endContactPayment(surname: surname,
                              name: name,
                              secondName: secondName,
                              amount: amount) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }
    
    func goToConfurmVC(with model: ConfurmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.confurmVCModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getCardList(completion: @escaping (_ error: String?)->()) {
        showActivity()
        
        NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error)
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                completion(nil)
                guard let data  = model.data else { return }
                guard let cardNumber  = model.data?.first?.original?.number else { return }
                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    self.cardField.text = data.first?.original?.name ?? ""
                    self.cardField.balanceLabel.text = "\(data.first?.original?.balance ?? 0) ₽"
                    guard let maskCard = data.first?.original?.numberMasked else { return }
                    self.cardField.bottomLabel.text = "•••• " + String(maskCard.suffix(4))
                    
                    //TODO: ------------ замокано для показа
                    self.bankField.text = "АйДиБанк"
                    self.bankField.imageView.image = #imageLiteral(resourceName: "IdBank")
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
    }
    
    func startContactPayment(with card: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
        var puref = ""
        guard let country = country else { return }
        if country.code == "AM" {
            puref = "iSimpleDirect||TransferIDClient11P"
            
//            iSimpleDirect||TransferIDClient11P    Перевод в АйДиБанк
//            iSimpleDirect||TransferEvocaClientP   Перевод в ЭвокаБанк
//            iSimpleDirect||TransferArmBBClientP   Перевод в АрмББ
//            iSimpleDirect||TransferArdshinClientP Перевод в АрдшинБанк
            
        } else {
            puref = "iFora||Addressless"
        }
        let body = ["accountID": nil,
                    "cardID": nil,
                    "cardNumber": card,
                    "provider": nil,
                    "puref": puref] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], body, completion: { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(nil)
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    if error != nil {
                        print("DEBUG: Error: ", error ?? "")
                        completion(error!)
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success ")
                        completion(nil)
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        })
    }
    
    func endMigPayment(phone: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
//        37477404102
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "RECP",
              "fieldvalue": phone ],
            [ "fieldid": 1,
              "fieldname": "SumSTrs",
              "fieldvalue": amount ]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                self.dismissActivity()
                guard let country = self.country else { return }
                let model = ConfurmViewControllerModel(
                    country: country,
                    model: model)
                self.goToConfurmVC(with: model)
                
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
    }
    
    func endContactPayment(surname: String, name: String, secondName: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
        let dataName = [ "additional": [
            ["fieldid": 1,
             "fieldname": "bName",
             "fieldvalue": surname ],
            ["fieldid": 2,
             "fieldname": "bLastName",
             "fieldvalue": name ],
            [ "fieldid": 3,
              "fieldname": "bSurName",
              "fieldvalue": secondName ],
            [ "fieldid": 4,
              "fieldname": "trnPickupPoint",
              "fieldvalue": "BTOC" ]
        ] ] as [String: AnyObject]
//        print("DEBUG: ", dataName)
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            
            print("DEBUG: amount", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Name")
                let dataAmount = [ "additional": [
                    [ "fieldid": 1,
                      "fieldname": "A",
                      "fieldvalue": amount ],
                    [ "fieldid": 2,
                      "fieldname": "CURR",
                      "fieldvalue": "RUR" ]
                ] ] as [String: AnyObject]
                
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataAmount) { model, error in
                    if error != nil {
                        print("DEBUG: Error: ", error ?? "")
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success send sms code")
                        self.dismissActivity()
                        
                        guard let country = self.country else { return }
                        let fullName = surname + " " + name + " " + secondName
                        let model = ConfurmViewControllerModel(
                            country: country,
                            model: model,
                            fullName: fullName)
                                                
                        self.goToConfurmVC(with: model)
                        
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
        
    }
    
}

