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
    var paymentSystem: PaymentSystemList?
    var cardFrom: GetProductListDatum? {
        didSet {
            guard let cardFrom = cardFrom else { return }
            if cardFrom.productType == "CARD" {
                if let cardID = cardFrom.id {
                    cardFromCardId = "\(cardID)"
                    cardFromAccountId = ""
                }
            } else if cardFrom.productType == "ACCOUNT" {
                if let accountID = cardFrom.id {
                    cardFromAccountId = "\(accountID)"
                    cardFromCardId = ""
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
            self.customCardTo = nil
            if cardTo.productType == "CARD" {
                if let cardID = cardTo.id {
                    cardToCardId = "\(cardID)"
                    cardToAccountId = ""
                }
            } else if cardTo.productType == "ACCOUNT" {
                if let accountID = cardTo.id {
                    cardToAccountId = "\(accountID)"
                    cardToCardId = ""
                }
            }
        }
    }
    var customCardTo: CastomCardViewModel? {
        didSet {
            guard let cardTo = customCardTo else { return }
            self.cardTo = nil
            cardToCardNumber = cardTo.cardNumber
            cardToCastomName = cardTo.cardName ?? ""
            if cardTo.cardId != nil {
                cardToCardId = "\(cardTo.cardId ?? 0)"
                cardToCardNumber = ""
            }
        }
    }
    
    var cardToCardId = ""
    var cardToCardNumber = ""
    var cardToAccountNumber = ""
    var cardToAccountId = ""
    var cardToCastomName = ""
    
    var payToCompany = false
    var comment = ""
    
    var bank : BanksList?
    
    var phone: String?
    var fullName: String? = "" {
        didSet {
            print("DEBUG: fullName", fullName ?? "")
        }
    }
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
        print("DEBUG:", model ?? "")
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
                    //
                    name = item.content?.first ?? ""
                } else if item.id == "RECO" {
                    //
                    secondName = item.content?.first ?? ""
                } else if item.id == "RECP" {
                    // телефон
                    phone = item.content?.first ?? ""
                } else if item.id == "trnReference" {
                    transctionNum = item.content?.first ?? ""
                } else if item.id == "RECFIO" {
                    fullName = item.content?.first ?? ""
                } else if item.id == "RECCURRENCY" {
                    curr = item.content?.first ?? ""
                } else if item.id == "RECAMOUNT" {
                    currAmount = item.content?.first ?? ""
                } else if item.id == "A" {
                    currAmount = item.content?.first ?? ""
                } else if item.id == "CURR" {
                    curr = item.content?.first ?? ""
                }
                
                
            }
        }
        if fullName.isEmpty {
            self.fullName = surname + " " + name + " " + secondName
        } else {
            self.fullName = fullName
        }
        
//        let currArr = Dict.shared.currencyList
//        currArr?.forEach({ currency in
//            if currency.code == curr {
//                print("DEBUG: currency", currency)
//            }
//        })
        self.summInCurrency = Double(currAmount)?.currencyFormatter(symbol: curr) ?? ""

        self.statusIsSuccses = model?.statusCode == 0 ? true : false
        self.phone = phone
        self.summTransction = Double(model?.data?.amount ?? 0).currencyFormatter(symbol: "RUB")
        self.taxTransction = Double(model?.data?.commission ?? 0).currencyFormatter(symbol: "RUB")
        self.numberTransction = transctionNum
        self.currancyTransction = "Наличные"
        self.country = country
    }
    
    enum PaymentType {
        case card2card
        case contact
        case mig
        case requisites
    }
    
}

class ContactConfurmViewController: UIViewController {
    
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }
    var otpCode: String = ""
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер телефона получателя",
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
    
    var cardFromField = CardChooseView()
        
    var cardToField = CardChooseView()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.setOtpCode(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)
    }
    
    @objc func setOtpCode(_ notification: NSNotification) {
        let otpCode = notification.userInfo?["body"] as! String
        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
        smsCodeField.text =  self.otpCode
        
    }
    
    func setupData(with model: ConfirmViewControllerModel) {
        currTransctionField.isHidden = true
        
        summTransctionField.text = model.summTransction
        taxTransctionField.text = model.taxTransction
        if model.taxTransction.isEmpty {
            taxTransctionField.isHidden = true
        }
        
        
        if model.paymentSystem != nil {
            let navImage: UIImage = model.paymentSystem?.svgImage?.convertSVGStringToImage() ?? UIImage()
            
            let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
            self.navigationItem.rightBarButtonItem = customViewItem
        }
        
        switch model.type {
        case .card2card:
            nameField.isHidden = true
            numberTransctionField.isHidden = true
            phoneField.isHidden = true
            bankField.isHidden = true
            countryField.isHidden = true
            currancyTransctionField.isHidden = true
                        
            guard let cardModelFrom = model.cardFrom else { return }
            cardFromField.cardModel = cardModelFrom
            
            let cardModelTo = model.cardTo
            let cardModelTemp = model.customCardTo
            
            if cardModelTo != nil {
                cardToField.cardModel = cardModelTo
            } else if cardModelTemp != nil {
                cardToField.customCardModel = cardModelTemp
            }
            
            
            var fromTitle = "Откуда"
            if cardModelFrom.productType == "CARD" {
                fromTitle = "С карты"
            } else if cardModelFrom.productType == "ACCOUNT" {
                fromTitle = "Со счета"
            }
            cardFromField.titleLabel.text = fromTitle
            
            var toTitle = "Куда"
            if cardModelTo?.productType == "CARD" {
                toTitle = "На карту"
            } else if cardModelTo?.productType == "ACCOUNT" {
                toTitle = "На счет"
            }
            if !model.summInCurrency.isEmpty {
                currTransctionField.isHidden = false
            }
            currTransctionField.text = model.summInCurrency
            cardToField.titleLabel.text = toTitle
            
            cardFromField.isHidden = false
            cardFromField.choseButton.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            
            cardToField.isHidden = false
            cardToField.choseButton.isHidden = true
            cardToField.balanceLabel.isHidden = true
            
//            {
//                "paymentOperationDetailId" : 2945,
//                "printFormType" : "internal"
//            }

        case .requisites:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            countryField.isHidden = true
            currancyTransctionField.isHidden = true
            phoneField.isHidden = true
            if model.payToCompany {
                nameField.imageView.isHidden = true
                nameField.viewModel.title = "Наименование получателя "
            }
            nameField.text =  model.fullName ?? ""
            if !model.cardToAccountNumber.isEmpty {
                bankField.viewModel.title = "Номер счета получателя"
                bankField.viewModel.image = #imageLiteral(resourceName: "accountIcon")
                bankField.text = model.cardToAccountNumber
            }
            
            if !model.comment.isEmpty {
                countryField.viewModel.title = "Назначение платежа"
                countryField.viewModel.image = #imageLiteral(resourceName: "comment")
                countryField.text = model.comment
            }
            
        case .mig:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            currancyTransctionField.isHidden = true
            countryField.isHidden = true
            numberTransctionField.isHidden = true
            
            bankField.text = model.bank?.memberNameRus ?? "" //"АйДиБанк"
            bankField.imageView.image = model.bank?.svgImage?.convertSVGStringToImage()
            
            nameField.text =  model.fullName ?? "" //"Колотилин Михаил Алексеевич"
            countryField.text = model.country?.name?.capitalizingFirstLetter() ?? "" // "Армения"
            numberTransctionField.text = model.numberTransction  //"1235634790"
            
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: model.phone)
            
            phoneField.text = maskPhone ?? ""

            if !model.summInCurrency.isEmpty {
                currTransctionField.isHidden = false
            }
            currTransctionField.text = model.summInCurrency
            
            
        default:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            nameField.text =  model.fullName ?? "" //"Колотилин Михаил Алексеевич"
            countryField.text = model.country?.name?.capitalizingFirstLetter() ?? "" // "Армения"
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
        view.backgroundColor = .white
        
        let stackView = UIStackView(
            arrangedSubviews: [phoneField, nameField, bankField, countryField, numberTransctionField, cardFromField, cardToField, summTransctionField, taxTransctionField, currTransctionField, currancyTransctionField, smsCodeField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20)
        
        view.addSubview(doneButton)        
        doneButton.anchor(left: stackView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: stackView.rightAnchor,
                          paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 44)
    }
    
    @objc func doneButtonTapped() {
        print(#function)
        guard var code = smsCodeField.textField.text else { return }
        if code.isEmpty {
            code = "0"
        }
        let body = ["verificationCode": code] as [String: AnyObject]
        print("DEBUG: PaymentMake body", body)
        showActivity()
        
        switch confurmVCModel?.type {
        
        case .card2card, .requisites:
            print(#function, body)
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
                        vc.id = model.data?.paymentOperationDetailId ?? 0
                        switch self.confurmVCModel?.type {
                        case .card2card:
                            vc.printFormType = "internal"
                        case .requisites:
                            vc.printFormType = "external"
                        default:
                            break
                        }
                        
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
                        if self.confurmVCModel?.type == .mig {
                            vc.printFormType =  "direct"
                        } else if self.confurmVCModel?.type == .contact {
                            vc.printFormType =  "contactAddressless"
                        }
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

