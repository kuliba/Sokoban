//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ContactInputViewController: UIViewController {
    
    let popView = CastomPopUpView()
    var typeOfPay: PaymentType = .contact {
        didSet {
            self.startPayment(with: selectedCardNumber, type: typeOfPay) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }
    var selectedCardNumber = "" {
        didSet {
            self.isFirstStartPayment = false
            self.startPayment(with: selectedCardNumber, type: typeOfPay) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }
    var isFirstStartPayment = true
    var needShowSwitchView: Bool = false {
        didSet {
            foraSwitchView.isHidden = needShowSwitchView ? false : true
        }
    }
    
    var country: Country? {
        didSet {
            if country?.code == "AM" {
                self.typeOfPay = .migAIbank
                self.configure(with: country, byPhone: true)
            } else {
                self.typeOfPay = .contact
                self.configure(with: country, byPhone: false)
            }
        }
    }
    var foraSwitchView = ForaSwitchView()
    
    var surnameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Фамилия получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            errorText: "Фамилия указана не верно"))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя получателя",
            errorText: "Имя указана не верно"))
    
    var secondNameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество получателя (если есть)"))
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            type: .phone))
    
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
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
    
    var cardListView = CardListView()
    var stackView = UIStackView(arrangedSubviews: [])
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        setupActions()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstStartPayment {
            self.startPayment(with: selectedCardNumber, type: typeOfPay) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }
    
    //MARK: - Actions
    @objc func titleDidTaped() {
        print("countryField didChooseButtonTapped")
        let vc = ChooseCountryTableViewController()
        vc.modalPresent = true
        vc.didChooseCountryTapped = { (country) in
            self.country = country
        }
        let navVc = UINavigationController(rootViewController: vc)
        self.present(navVc, animated: true, completion: nil)
    }
    
    func setupActions() {
        getCardList {data ,error in
            DispatchQueue.main.async {
                
                //TODO: ------------ замокано для показа
                self.bankField.text = "АйДиБанк"
                self.bankField.imageView.image = #imageLiteral(resourceName: "IdBank")
                
                
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                self.cardListView.cardList = data
                
                if data.count > 0 {
                    self.cardField.configCardView(data.first!)
                    guard let cardNumber  = data.first?.original?.number else { return }
                    self.selectedCardNumber = cardNumber
                }
            }
        }
        
        foraSwitchView.switchIsChanged = { (switchView) in
            self.typeOfPay = switchView.isOn ? .migAIbank : .contact
            self.configure(with: self.country, byPhone: switchView.isOn)
        }
        
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
//            self.popView.showAlert()
            UIView.animate(withDuration: 0.2) {
                self.cardListView.isHidden.toggle()
            }
        }
        
        bankField.didChooseButtonTapped = { () in
            print("bankField didChooseButtonTapped")
            
        }
        
        cardListView.didCardTapped = { card in
            self.cardField.configCardView(card)
            self.selectedCardNumber = card.original?.number ?? ""
            UIView.animate(withDuration: 0.2) {
                self.cardListView.isHidden.toggle()
            }
        }
    }
    
    @objc func doneButtonTapped() {
        let amount = summTransctionField.textField.text ?? ""
        let doubelAmount = amount.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
        
        switch typeOfPay {
        case .migAIbank:
            let phone = phoneField.textField.unmaskedText ?? ""
            
            endMigPayment(phone: phone, amount: doubelAmount) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        default:
            let surname = surnameField.textField.text ?? ""
            let name = nameField.textField.text ?? ""
            let secondName = secondNameField.textField.text ?? ""
            
            endContactPayment(surname: surname,
                              name: name,
                              secondName: secondName,
                              amount: doubelAmount) { error in
                self.dismissActivity()
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
    }
    
    //MARK: - Helpers
    func goToConfurmVC(with model: ConfirmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.confurmVCModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - API
    func getCardList(completion: @escaping (_ cardList: [Datum]?,_ error: String?)->()) {
        showActivity()
        
        NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, [:], [:]) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(nil,error)
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                completion(data, nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(nil ,model.errorMessage)
            }
        }
        
    }
    
    
    func startPayment(with card: String, type: PaymentType,
                             completion: @escaping (_ error: String?)->()) {
        showActivity()
        let puref = type.puref
        
        print("DEBUG: Puref: ", puref)
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
                let model = ConfirmViewControllerModel(
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
                        let model = ConfirmViewControllerModel(
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
    
    
    enum PaymentType {
        case contact
        case migAIbank
        case migEvoka
        case migArmBB
        case migArdshin
        
        var puref: String {
            switch self {
            case .contact:
                return "iSimpleDirect||TransferIDClient11P"
            case .migAIbank:
                return "iSimpleDirect||TransferIDClient11P"
            case .migEvoka:
                return "iSimpleDirect||TransferEvocaClientP"
            case .migArmBB:
                return "iSimpleDirect||TransferArmBBClientP"
            case .migArdshin:
                return "iSimpleDirect||TransferArdshinClientP"
            }
        }
    }
    
    
//          "iSimpleDirect||TransferIDClient11P"
//            iSimpleDirect||TransferIDClient11P    Перевод в АйДиБанк
//            iSimpleDirect||TransferEvocaClientP   Перевод в ЭвокаБанк
//            iSimpleDirect||TransferArmBBClientP   Перевод в АрмББ
//            iSimpleDirect||TransferArdshinClientP Перевод в АрдшинБанк
    
}

