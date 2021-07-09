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
            if cardFrom.productType == "CARD" {
                if let cardID = cardFrom.id {
                    cardFromCardId = "\(cardID)"
                }
            } else if cardFrom.productType == "ACCOUNT" {
                if let accountID = cardFrom.id {
                    cardFromAccountId = "\(accountID)"
                }
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
            if cardTo.productType == "CARD" {
                if let cardID = cardTo.id {
                    cardToCardId = "\(cardID)"
                }
            } else if cardTo.productType == "ACCOUNT" {
                if let accountID = cardTo.id {
                    cardToAccountId = "\(accountID)"
                }
            }
        }
    }
    var cardToCardId = ""
    var cardToCardNumber = ""
    var cardToAccountNumber = ""
    var cardToAccountId = ""
    
    var bank : BanksList?
    
    var phone: String?
    var fullName: String? = ""
    var country: CountriesList?
    var numberTransction: String = ""
    var summTransction: String = ""
    var taxTransction: String = ""
    var currancyTransction: String = ""
    var statusIsSuccses: Bool = false
    var summInCurrency = ""
    
    init(type: PaymentType) {
        self.type = type
    }
    
    init?(country: CountriesList, model: AnywayPaymentDecodableModel?, fullName: String? = nil) {
        self.type = .contact
        var name = ""
        var surname = ""
        var secondName = ""
        var phone = ""
        var transctionNum = ""
        var fullName = fullName ?? ""
        var curr = ""
        var currAmount = ""
        if let listInputs = model?.data?.listInputs {
            for item in listInputs {
                if item.id == "RECF" {
                    surname = item.content?.first ?? ""
                } else if item.id == "RECI" {
                    self.type = .mig
                    name = item.content?.first ?? ""
                } else if item.id == "RECO" {
                    self.type = .mig
                    secondName = item.content?.first ?? ""
                } else if item.id == "RECP" {
                    self.type = .mig
                    phone = item.content?.first ?? ""
                } else if item.id == "trnReference" {
                    transctionNum = item.content?.first ?? ""
                } else if item.id == "RECFIO" {
                    self.type = .mig
                    fullName = item.content?.first ?? ""
                } else if item.id == "RECCURRENCY" {
                    self.type = .mig
                    curr = item.content?.first ?? ""
                } else if item.id == "RECAMOUNT" {
                    self.type = .mig
                    currAmount = item.content?.first ?? ""
                }
                
                
            }
        }
        if fullName.isEmpty {
//            self.fullName = fullName
//        } else {
            self.fullName = surname + " " + name + " " + secondName
        }
        self.summInCurrency = Double(currAmount)?.currencyFormatter(code: curr) ?? ""
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
    
    var cardFromField = ForaInput(
        viewModel: ForaInputModel(
            title: "С карты",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false,
            showChooseButton: true))
    
    var cardToField = ForaInput(
        viewModel: ForaInputModel(
            title: "На карту",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false,
            showChooseButton: false))
    
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
    
    var currTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма зачисления в валюте",
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
        currTransctionField.isHidden = true
        
        let amount = Double(model.summTransction)?.currencyFormatter(code: "RUB")
        summTransctionField.text = amount ?? ""
        let tax = Double(model.taxTransction)?.currencyFormatter(code: "RUB")
        taxTransctionField.text = tax ?? ""
        
        
        switch model.type {
        case .card2card:
            nameField.isHidden = true
            numberTransctionField.isHidden = true
            phoneField.isHidden = true
            bankField.isHidden = true
            countryField.isHidden = true
            currancyTransctionField.isHidden = true
            
//            let amount = Double(model.summTransction)?.currencyFormatter()
//            summTransctionField.text = amount ?? "" // .currencyFormatter()
//            let tax = Double(model.taxTransction)?.currencyFormatter()
//            taxTransctionField.text = tax ?? ""
            
            guard let cardModelFrom = model.cardFrom else { return }
            guard let cardModelTo = model.cardTo else { return }
            cardFromField.configCardView(cardModelFrom)
            cardToField.configCardView(cardModelTo)
            
            cardFromField.isHidden = false
            cardFromField.viewModel.showChooseButton = false
            cardFromField.chooseButton.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            
            cardToField.isHidden = false
            cardToField.viewModel.showChooseButton = false
            cardToField.chooseButton.isHidden = true
            cardToField.balanceLabel.isHidden = true
        case .mig:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            
            nameField.text =  model.fullName ?? "" //"Колотилин Михаил Алексеевич"
            countryField.text = model.country?.name ?? "" // "Армения"
            numberTransctionField.text = model.numberTransction  //"1235634790"
            

            
            if !model.summInCurrency.isEmpty {
                currTransctionField.isHidden = false
            }
            
            cardFromField.isHidden = false
            cardFromField.viewModel.showChooseButton = false
            cardFromField.chooseButton.isHidden = true
            cardFromField.balanceLabel.isHidden = true
        default:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            nameField.text =  model.fullName ?? "" //"Колотилин Михаил Алексеевич"
            countryField.text = model.country?.name ?? "" // "Армения"
            numberTransctionField.text = model.numberTransction  //"1235634790"
            
            
            currancyTransctionField.text = model.currancyTransction //"Наличные"
            
            
            if model.country?.code == "AM" {
                numberTransctionField.isHidden = true
                phoneField.isHidden = false
                phoneField.textField.maskString = "+000-0000-00-00"
                phoneField.text = model.phone ?? ""
                
                bankField.isHidden = false
                bankField.text = model.bank?.memberNameRus ?? ""
                bankField.imageView.image = model.bank?.svgImage?.convertSVGStringToImage()
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
        
        smsCodeField.textField.textContentType = .oneTimeCode
        
    }
    
    fileprivate func setupUI() {
        title = "Подтвердите реквизиты"
        view.backgroundColor = .white
        
        let stackView = UIStackView(
            arrangedSubviews: [phoneField, nameField, bankField, countryField, numberTransctionField, cardFromField, cardToField, summTransctionField, taxTransctionField, currTransctionField, currancyTransctionField, smsCodeField, doneButton])
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
        
        switch confurmVCModel?.type {
        
        case .card2card:
            print(#function)
            NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { respons, error in
                if error != nil {
                    self.dismissActivity()
                    print("DEBUG: Error: ", error ?? "")
                    self.showAlert(with: "Ошибка", and: error ?? "")
                }
                guard let model = respons else { return }
                
                if model.statusCode == 0 {
                    print("DEBUG: Success payment")
                    self.dismissActivity()
                    DispatchQueue.main.async {
                        let vc = PaymentsDetailsSuccessViewController()
                        vc.confurmVCModel = self.confurmVCModel
//                        vc.id = model.data?.paymentOperationDetailID
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    self.dismissActivity()
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                }
            }
            
        default:
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
    

}

