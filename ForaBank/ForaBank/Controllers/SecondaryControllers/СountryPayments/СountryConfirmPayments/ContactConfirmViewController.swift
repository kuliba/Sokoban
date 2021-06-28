//
//  ContactConfurmViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 30.05.2021.
//

import UIKit


//TODO: отрефакторить под сетевые запросы, вынести в отдельный файл
struct ConfirmViewControllerModel {
    
    var type: PaymentType
    var cardFrom: GetProductListDatum? {
        didSet {
            guard let cardFrom = cardFrom else { return }
            if let cardID = cardFrom.id {
                cardFromCardId = "\(cardID)"
            }
        }
    }
    var cardFromCardId = ""
    var cardFromCardNumber = ""
    var cardFromExpireDate = ""
    var cardFromCardCVV = ""
    var cardFromAccountId = ""
    var cardFromAccountNumber = ""
    
    var cardTo: GetProductListDatum? {
        didSet {
            guard let cardTo = cardTo else { return }
            if let cardID = cardTo.id {
                cardToCardId = "\(cardID)"
            }
        }
    }
    var cardToCardId = ""
    var cardToCardNumber = ""
    var cardToAccountNumber = ""
    var cardToAccountId = ""
    
    var phone: String?
    var fullName: String? = ""
    var country: Country?
    var numberTransction: String = ""
    var summTransction: String = ""
    var taxTransction: String = ""
    var currancyTransction: String = ""
    var statusIsSuccses: Bool = false
    
    
    init(type: PaymentType) {
        self.type = type
    }
    
    init?(country: Country, model: AnywayPaymentDecodableModel?, fullName: String? = nil) {
        self.type = .contact
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
            self.fullName = fullName
        } else {
            self.fullName = surname + " " + name + " " + secondName
        }
        self.statusIsSuccses = model?.statusCode == 0 ? true : false
        self.phone = phone
        self.summTransction = Double(model?.data?.amount ?? 0).currencyFormatter()
        self.taxTransction = (model?.data?.commission ?? 0).currencyFormatter()
        self.numberTransction = transctionNum
        self.currancyTransction = "Наличные"
        self.country = country
    }
    
    enum PaymentType {
        case card2card
        case contact
        case mig
    }
    
}

class ContactConfurmViewController: UIViewController {
    
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            type: .phone,
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
    
    let doneButton = UIButton(title: "Оплатить")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doneButton.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
    }
    
    func setupData(with model: ConfirmViewControllerModel) {
        nameField.text =  model.fullName ?? "" //"Колотилин Михаил Алексеевич"
        countryField.text = model.country?.name ?? "" // "Армения"
        numberTransctionField.text = model.numberTransction  //"1235634790"
        summTransctionField.text = model.summTransction  //"10 000.00 ₽ "
        taxTransctionField.text = model.taxTransction //"100.00 ₽ "
        currancyTransctionField.text = model.currancyTransction //"Наличные"
        smsCodeField.textField.textContentType = .oneTimeCode
        
        if model.country?.code == "AM" {
            numberTransctionField.isHidden = true
            phoneField.isHidden = false
            phoneField.textField.maskString = "+000-0000-00-00"
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
        
        let stackView = UIStackView(arrangedSubviews: [phoneField, nameField, bankField, countryField, numberTransctionField, summTransctionField, taxTransctionField, currancyTransctionField, smsCodeField, doneButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20)
        
        doneButton.anchor(left: stackView.leftAnchor, right: stackView.rightAnchor,
                          paddingLeft: 20, paddingRight: 20, height: 44)
    }
    
    @objc func doneButtonTapped() {
        print(#function)
        guard let code = smsCodeField.textField.text else { return }
        let body = ["verificationCode": code] as [String: AnyObject]
        showActivity()
        NetworkManager<AnywayPaymentMakeDecodableModel>.addRequest(.anywayPaymentMake, [:], body) { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                self.showAlert(with: "Ошибка", and: error ?? "")
            }
            guard let model = model else { return }
            
            if model.statusCode == 0 {
                print("DEBUG: Success payment")
                self.dismissActivity()
                DispatchQueue.main.async {
                    let vc = PaymentsDetailsSuccessViewController()
                    vc.confurmVCModel = self.confurmVCModel
                    vc.id = model.data?.paymentOperationDetailID
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
            }
        }


    }
    

}

