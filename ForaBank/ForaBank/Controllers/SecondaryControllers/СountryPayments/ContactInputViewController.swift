//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ContactInputViewController: UIViewController {

    var country: Сountry? {
        didSet {
            guard let country = country else { return }
            if country.code == "AM" {
                title = "Денежные переводы Миг"
            } else {
                title = "Денежные переводы Contact"
            }
            guard let countryName = country.name else { return }
            countryField.textField.text = countryName
            countryField.text = countryName
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
        }
        getCardList()
    }

    fileprivate func setupUI() {
        
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "Vector")))
        self.navigationItem.rightBarButtonItem = customViewItem
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
        
        
        let stackView = UIStackView(arrangedSubviews: [foraSwitchView, surnameField, nameField, secondNameField, countryField ,summTransctionField, cardField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 20)
        
    }
    
    @objc func doneButtonTapped() {
        endContactPayment(surname: surnameField.textField.text ?? "", name: nameField.textField.text ?? "", secondName: secondNameField.textField.text ?? "", amount: summTransctionField.textField.text ?? "")
    }
    
    func goToConfurmVC(with model: ConfurmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.confurmVCModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getCardList() {
        showActivity()
        NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, [:], [:]) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                guard let cardNumber  = model.data?.first?.original?.number else { return }
                self.startContactPayment(with: cardNumber)
                DispatchQueue.main.async {
                    self.cardField.text = data.first?.original?.name ?? ""
                    self.cardField.balanceLabel.text = "\(data.first?.original?.balance ?? 0) ₽"
                    guard let maskCard = data.first?.original?.numberMasked else { return }
                    self.cardField.bottomLabel.text = "•••• " + String(maskCard.suffix(4))
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
    func startContactPayment(with card: String) {
        showActivity()
        let body = ["accountID": nil,
                    "cardID": nil,
                    "cardNumber": card,
                    "provider": nil,
                    "puref": "iFora||Addressless"] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], body, completion: { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    if error != nil {
                        print("DEBUG: Error: ", error ?? "")
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success ")
                        self.dismissActivity()
                        
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        })
    }
    
    func endContactPayment(surname: String, name: String, secondName: String, amount: String) {
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
        print("DEBUG: ", dataName)
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            
            print("DEBUG: amount ", amount)
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
                    
                        let model = ConfurmViewControllerModel(
                            name: surname + " " + name + " " + secondName,
                            country: self.countryField.viewModel.text,
                            numberTransction: "\(model.data?.listInputs?[0].content?.first ?? "")",
                            summTransction: "\(model.data?.listInputs?[1].content?[0] ?? "") ₽",
                            taxTransction: "\(model.data?.commission ?? 0) ₽",
                            currancyTransction: "Наличные")
                        
                        self.goToConfurmVC(with: model)
                        
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
        
    }
    
}

