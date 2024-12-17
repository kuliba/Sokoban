//
//  ContactConfurmViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 30.05.2021.
//

import UIKit
import SwiftUI
import Combine
import IQKeyboardManagerSwift

//TODO: отрефакторить под сетевые запросы, вынести в отдельный файл
class ConfirmViewControllerModel {
    
    var operatorsViewModel: OperatorsViewModel?
    static var svgIcon = ""
    var type: PaymentType
    var paymentSystem: PaymentSystemList?
    var templateButtonViewModel: TemplateButtonViewModel?
    var template: PaymentTemplateData?
    var closeAction: () -> Void = {}
    
    var cardFromRealm: UserAllCardsModel? {
        didSet {
            guard let cardFrom = cardFromRealm else { return }
            if cardFrom.productType == "CARD" {
                cardFromCardId = "\(cardFrom.id)"
                cardFromAccountId = ""
            } else if cardFrom.productType == "ACCOUNT" {
                cardFromAccountId = "\(cardFrom.id)"
                cardFromCardId = ""
            } else if cardFrom.productType == "DEPOSIT" {
                cardFromAccountId = "\(cardFrom.accountID)"
                cardFromCardId = ""
            }
        }
    }
    
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
    var operatorImage = ""
    var antifraudStatus = ""
    
    var cardToRealm: UserAllCardsModel? {
        didSet {
            guard let cardTo = cardToRealm else { return }
            self.customCardTo = nil
            if cardTo.productType == "CARD" {
                cardToCardId = "\(cardTo.id)"
                cardToAccountId = ""
            } else if cardTo.productType == "ACCOUNT"  {
                cardToAccountId = "\(cardTo.id)"
                cardToCardId = ""
            } else if cardTo.productType == "DEPOSIT" {
                cardToAccountId = "\(cardTo.accountID)"
                cardToCardId = ""
            }
        }
    }
    
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
    
    // ЖКХ
    var gkhModel: GkhPaymentModel? = nil
    
    
    var cardToCardId = ""
    var cardToCardNumber = ""
    var cardToAccountNumber = ""
    var cardToAccountId = ""
    var cardToCastomName = ""
    
    var payToCompany = false
    var comment = ""
    
    var bank : BanksList?
    var dateOfTransction: String = ""
    var phone: String?
    var fullName: String? = ""
    var country: CountriesList?
    var numberTransction: String = ""
    var paymentOperationDetailId: Int = 0
    var summTransction: String = ""
    var taxTransction: String = ""
    var currancyTransction: String = ""
    var status: StatusOperation
    var summInCurrency = ""
    var name: String? = ""
    var surname: String? = ""
    var secondName: String? = ""
    
    init(
        type: PaymentType,
        status: StatusOperation
    ) {
        self.type = type
        self.status = status
    }
    
    enum StatusOperation {
        case antifraudCanceled
        case inProgress
        case succses
        case error
        case returnRequest
        case changeRequest
        case processing
        case timeOut
    }
    
    enum PaymentType {
        case card2card
        case contact
        case mig
        case requisites
        case phoneNumber
        case phoneNumberSBP
        case gkh
        case mobilePayment
        case openDeposit
        case closeDeposit

        //BANK_DEF, BEST2PAY, CHANGE_OUTGOING, CONTACT_ADDRESSING, CONTACT_ADDRESSLESS, DIRECT, ELECSNET, EXTERNAL, HOUSING_AND_COMMUNAL_SERVICE, INTERNAL, INTERNET, ME2ME_CREDIT, ME2ME_DEBIT, MOBILE, OTH, RETURN_OUTGOING, SFP
        
        init?(with transferType: StringLiteralType) {
            
            switch transferType {
            case "ME2ME_CREDIT", "ME2ME_DEBIT":
                self = .card2card
                
            case "CONTACT_ADDRESSING", "CONTACT_ADDRESSLESS":
                self = .contact
                
            case "DIRECT":
                self = .mig
                
            case "EXTERNAL":
                self = .requisites
                
            case "INTERNAL":
                self = .phoneNumber
                
            case "HOUSING_AND_COMMUNAL_SERVICE":
                self = .gkh
                
            case "MOBILE":
                self = .mobilePayment
                
            case "OTH":
                self = .openDeposit
                
            case "SFP":
                self = .phoneNumberSBP
            
            default:
                return nil
            }
        }
    }
}

class ContactConfurmViewController: UIViewController {
    
    var operatorsViewModel: OperatorsViewModel?
    var getUImage: (Md5hash) -> UIImage? = { _ in UIImage() }
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }
    var operatorView = ""
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
            image: UIImage(named: "map-pin")!,
            isEditable: false))
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: UIImage(named: "hash")!,
            isEditable: false))
    
    var cardFromField = CardChooseView()
        
    var cardToField = CardChooseView()
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: UIImage(named: "coins")!,
            isEditable: false))
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var purposePaymentField = ForaInput(
        viewModel: ForaInputModel(
            title: "purposePaymentField",
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
            image: UIImage(named: "message-square")!,
            type: .smsCode))
    
    let doneButton = UIButton(title: "Оплатить")
    var createTransferSBP: CreateSFPTransferDecodableModel?
    var cancelledPayment = false
    var buttonTapped: (() -> Void)?

    var fromTitle = "От куда"
    var toTitle = "Куда"
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doneButton.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setOtpCode(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)
        let statusValue = createTransferSBP?.data?.additionalList?.filter({$0.fieldName == "AFResponse"})
        if statusValue?[0].fieldValue == "G" {
        
        } else {
            
            guard let data = self.createTransferSBP else {
                return
            }
            
            self.presentSwiftUIView(data: AntifraudViewModel(model: data, phoneNumber: self.phoneField.text))

        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("dismissSwiftUI"), object: nil, queue: nil) { data in
            
            let vc = PaymentsDetailsSuccessViewController()
            vc.confurmView.statusImageView.image = UIImage(named: "waiting")
            vc.confurmView.summLabel.text = self.summTransctionField.text
            vc.confurmView.statusLabel.text = "Перевод отменен!"
            vc.confurmView.operatorImageView.image = UIImage(named: "sbp-long")
            vc.confurmView.statusLabel.textColor = .red
            vc.confurmView.detailButtonsStackView.isHidden = true
            vc.operatorsViewModel = self.operatorsViewModel
            if data.userInfo?.count ?? 0 > 0{
                vc.confurmView.infoLabel.text = "Время на подтверждение\n перевода вышло"
                vc.confurmView.infoLabel.isHidden = false
                
            } else {
                vc.confurmView.infoLabel.text = ""
            }

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func setOtpCode(_ notification: NSNotification) {

        let otpCode: String
        
        if let dict = notification.userInfo as NSDictionary? {
            
            if let code = dict["otp"] as? String {
                
                otpCode = code
            } else if let code = dict["aps.alert.body"] as? String {
                otpCode = code
            } else {
                return
            }
        } else {
            return
        }
        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
        smsCodeField.text =  self.otpCode
    }
    
    
    func presentSwiftUIView(data: AntifraudViewModel) {
        guard let dataTransfer = createTransferSBP else {
            return
        }

        let hostVC = AntifraudViewHostingController(with: AntifraudViewModel(model: dataTransfer, phoneNumber: data.phoneNumber))
        
        present(hostVC, animated: true)
    }
    
    func setupData(with model: ConfirmViewControllerModel) {
        currTransctionField.isHidden = true
        summTransctionField.text = model.summTransction
        taxTransctionField.text = model.taxTransction

        cardFromField.getUImage = getUImage
        cardToField.getUImage = getUImage
        
        if model.taxTransction.isEmpty {
            taxTransctionField.isHidden = true
        }
        
        purposePaymentField.isHidden = true
        
        if model.paymentSystem != nil {
            let navImage: UIImage = model.paymentSystem?.svgImage?.convertSVGStringToImage() ?? UIImage()
            
            let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
            self.navigationItem.rightBarButtonItem = customViewItem
        }
        
        switch model.type {
        case .openDeposit:
            cardToField.isHidden = true
            taxTransctionField.isHidden = true
            currTransctionField.isHidden = true
            currancyTransctionField.isHidden = true
            smsCodeField.isHidden = true
            
            phoneField.isHidden = false
            phoneField.viewModel.title = "Наименование вклада"
            phoneField.viewModel.image = UIImage(named: "depositIcon")!
            phoneField.text = model.fullName ?? ""
            
            nameField.isHidden = false
            nameField.viewModel.title = "Срок вклада"
            nameField.viewModel.image = UIImage(named: "date")!
            nameField.text = model.phone ?? ""
            
            bankField.isHidden = false
            bankField.viewModel.title = "Процентная ставка"
            bankField.viewModel.image = #imageLiteral(resourceName: "Frame 580")
            bankField.text = model.summInCurrency
            
            countryField.isHidden = false
            countryField.viewModel.title = "Сумма вклада"
            countryField.viewModel.image = UIImage(named: "coins")!
            countryField.text = model.summTransction
            
            numberTransctionField.isHidden = false
            numberTransctionField.viewModel.title = "Ваш потенциальный доход"
            numberTransctionField.viewModel.image = #imageLiteral(resourceName: "Frame 579")
            numberTransctionField.text = model.taxTransction
            
            
            summTransctionField.isHidden = false
            summTransctionField.viewModel.title = "Счет вклада"
            summTransctionField.viewModel.image = UIImage(named: "depositIcon-1")!
            summTransctionField.text = model.numberTransction
            
            cardFromField.isHidden = false
            cardFromField.choseButton?.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            cardFromField.leftTitleAncor.constant = 64
            cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            cardFromField.model = model.cardFromRealm
            
        case .card2card:
            
            currTransctionField.text = model.summInCurrency
            cardToField.model = model.cardToRealm
            cardFromField.model = model.cardFromRealm
            
            nameField.isHidden = true
            numberTransctionField.isHidden = true
            phoneField.isHidden = true
            bankField.isHidden = true
            countryField.isHidden = true
            currancyTransctionField.isHidden = true
            
            cardFromField.isHidden = false
            cardFromField.choseButton?.isHidden = true
            cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            cardFromField.balanceLabel.isHidden = true
            cardFromField.leftTitleAncor.constant = 64
            
            
            cardFromField.titleLabel.text = fromTitle
            
            
            cardToField.isHidden = false
            cardToField.choseButton?.isHidden = true
            cardToField.balanceLabel.isHidden = true
            cardToField.leftTitleAncor.constant = 64
            
            
            cardToField.titleLabel.text = toTitle
            
            if !model.summInCurrency.isEmpty {
                currTransctionField.isHidden = false
            }
            
        case .phoneNumber, .phoneNumberSBP:
            cardToField.isHidden = true
            countryField.isHidden = true
            
            currancyTransctionField.isHidden = true
            
            numberTransctionField.isHidden = true
            let mask = StringMask(mask: "0 (000) 000-00-00")
            let maskPhone = mask.mask(string: model.phone)
            if model.payToCompany == true, model.type == .phoneNumberSBP{
                numberTransctionField.isHidden = false
                numberTransctionField.text = model.numberTransction
            }
            if model.type == .phoneNumberSBP{
                var sbpimage = UIImage()
                
                let paymentSystems = Model.shared.paymentSystemList.value.map { $0.getPaymentSystem() }
                
                for system in paymentSystems {
                    if system.code == "SFP" {
                        sbpimage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
                    }
                } 
                
                let imageView = UIImageView(image: sbpimage)
                let item = UIBarButtonItem(customView: imageView)
                imageView.contentMode = .scaleAspectFit
                imageView.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
                self.navigationItem.rightBarButtonItem = item
            }
            phoneField.text = maskPhone ?? ""
            nameField.text =  model.fullName ?? ""
            bankField.text = model.bank?.memberNameRus ?? "" //"АйДиБанк"
            bankField.imageView.image = model.bank?.svgImage?.convertSVGStringToImage()

            cardFromField.model = model.cardFromRealm
            cardFromField.isHidden = false
            cardFromField.choseButton?.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            cardFromField.titleLabel.text = "Счет списания"
            cardFromField.leftTitleAncor.constant = 64
          
            
        case .mobilePayment:
            cardToField.isHidden = true
            countryField.isHidden = true
            bankField.isHidden = true
            currancyTransctionField.isHidden = true
            nameField.isHidden = true
            numberTransctionField.isHidden = true
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            let maskPhone = mask.mask(string: model.phone)
        
            phoneField.text = maskPhone ?? ""

            cardFromField.cardModel = model.cardFrom
            cardFromField.isHidden = false
            cardFromField.choseButton?.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            cardFromField.titleLabel.text = "Счет списания"
            cardFromField.leftTitleAncor.constant = 64
            
        case .requisites:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            countryField.isHidden = true
            numberTransctionField.isHidden = true
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
                countryField.isHidden = false
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
                currTransctionField.viewModel.image = UIImage(named: "coins")
                currTransctionField.text = model.summInCurrency
            }
            if model.paymentSystem != nil {
                let navImage: UIImage = model.paymentSystem?.svgImage?.convertSVGStringToImage() ?? UIImage()
                
                let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
                self.navigationItem.rightBarButtonItem = customViewItem
            }
            
            
        case .gkh:
            self.dismissActivity()
            cardFromField.cardModel = model.cardFrom
            cardFromField.isHidden = false
            cardFromField.choseButton?.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            cardFromField.titleLabel.text = "Счет списания"
            cardFromField.leftTitleAncor.constant = 64
            
        case .contact:
            cardFromField.isHidden = true
            cardToField.isHidden = true
            phoneField.isHidden = true
            bankField.isHidden = true
            numberTransctionField.isHidden = false
            numberTransctionField.text = model.numberTransction
            nameField.text =  model.fullName ?? ""
            countryField.text = model.country?.name?.capitalizingFirstLetter() ?? ""
            if !model.summInCurrency.isEmpty {
                currTransctionField.isHidden = false
                currTransctionField.viewModel.image = UIImage(named: "coins")
                currTransctionField.text = model.summInCurrency
            }
            currancyTransctionField.text = model.currancyTransction
            
            if model.paymentSystem != nil {
                let navImage: UIImage = model.paymentSystem?.svgImage?.convertSVGStringToImage() ?? UIImage()
                
                let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
                self.navigationItem.rightBarButtonItem = customViewItem
            }
        case .closeDeposit:
            
            currTransctionField.text = model.summInCurrency
            cardToField.model = model.cardToRealm
            cardFromField.model = model.cardFromRealm
            
            nameField.isHidden = true
            numberTransctionField.isHidden = true
            phoneField.isHidden = true
            bankField.isHidden = true
            countryField.isHidden = true
            currancyTransctionField.isHidden = true
            
            cardFromField.isHidden = false
            cardFromField.choseButton?.isHidden = true
            cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            cardFromField.balanceLabel.isHidden = true
            cardFromField.leftTitleAncor.constant = 64
            
            cardFromField.titleLabel.text = fromTitle
            
            cardToField.isHidden = false
            cardToField.choseButton?.isHidden = true
            cardToField.balanceLabel.isHidden = true
            cardToField.leftTitleAncor.constant = 64
            
            cardToField.titleLabel.text = toTitle
            
            if !model.summInCurrency.isEmpty {
                
                currTransctionField.isHidden = false
            }
            
            if !model.comment.isEmpty {
                
                purposePaymentField.isHidden = false
                purposePaymentField.viewModel.title = "Назначение платежа"
                purposePaymentField.text = "Назначение платежа"
                purposePaymentField.textField.isHidden = true
                purposePaymentField.imageView.image = #imageLiteral(resourceName: "comment")
                purposePaymentField.descriptionLabel.text = model.comment
                purposePaymentField.descriptionLabel.isHidden = false
                purposePaymentField.anchor(height: 100)
            }
            
            if !model.dateOfTransction.isEmpty {
                currancyTransctionField.isHidden = false
                currancyTransctionField.viewModel.title = "Тип платежа"
                currancyTransctionField.viewModel.image = #imageLiteral(resourceName: "date")
                currancyTransctionField.text = model.dateOfTransction

            }
        }
        
        var products: [UserAllCardsModel] = []
        
        let data = Model.shared.products.value
        
        for i in data {
            
            for i in i.value {
                
                products.append(i.userAllProducts())
            }
        }
    
        if let cardModelFrom = model.cardFrom {
            cardFromField.cardModel = cardModelFrom
            if cardModelFrom.productType == "CARD" {
                fromTitle = "С карты"
            } else if cardModelFrom.productType == "ACCOUNT" {
                fromTitle = "Со счета"
            }
        } else {
            if model.cardFromCardId != "" || model.cardFromAccountId != "" || model.cardFromCardNumber.digits.count != 0 {
                
                products.forEach({ card in
                    if String(card.id) == model.cardFromCardId || String(card.id) == model.cardFromAccountId || card.number?.suffix(4) == model.cardFromCardNumber.suffix(4) {
                        cardFromField.model = card
                        if card.productType == "CARD" {
                            fromTitle = "С карты"
                        } else if card.productType == "ACCOUNT" {
                            fromTitle = "Со счета"
                        }
                    }
                })
            }
        }
        
        
        if let cardModelTo = model.cardTo {
            cardToField.cardModel = cardModelTo
            if cardModelTo.productType == "CARD" {
                toTitle = "На карту"
            } else if cardModelTo.productType == "ACCOUNT" {
                toTitle = "На счет"
            }
        } else if let cardModelTemp = model.customCardTo {
            cardToField.customCardModel = cardModelTemp
            toTitle = "На карту"
        } else {
            if model.cardToCardId != "" || model.cardToAccountId != "" || model.cardToCardNumber != ""{
                products.forEach({ card in
                    if String(card.id) == model.cardToCardId || String(card.id) == model.cardToAccountId || card.number?.suffix(4) == model.cardToCardNumber.suffix(4){
                        cardToField.model = card
                        if card.productType == "CARD" {
                            toTitle = "На карту"
                        } else if card.productType == "ACCOUNT" {
                            toTitle = "На счет"
                        }
                    }
                })
            }
        }
        
        smsCodeField.textField.textContentType = .oneTimeCode
        
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(
            arrangedSubviews: [phoneField,
                               nameField,
                               bankField,
                               countryField,
                               numberTransctionField,
                               cardFromField,
                               cardToField,
                               summTransctionField,
                               taxTransctionField,
                               purposePaymentField,
                               currTransctionField,
                               currancyTransctionField,
                               smsCodeField])
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 20)
        
        view.addSubview(doneButton)        
        doneButton.anchor(left: stackView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: stackView.rightAnchor,
                          paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 44)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func doneButtonIsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.doneButton.backgroundColor = isEnabled ? #colorLiteral(red: 0.2980068028, green: 0.2980631888, blue: 0.3279978037, alpha: 1) : #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
                self.doneButton.isEnabled = isEnabled ? false : true
            }
        }
    }
    
    @objc func doneButtonTapped() {
        doneButtonIsEnabled(true)
        guard var code = smsCodeField.textField.text else { return }
        if code.isEmpty {
            code = "0"
        }
        let body = ["verificationCode": code] as [String: AnyObject]

        showActivity()
        
        switch confurmVCModel?.type {
        
        case .card2card, .requisites, .phoneNumber, .gkh, .mobilePayment:
            NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { response, error in
                if error != nil {
                    self.dismissActivity()
                    self.doneButtonIsEnabled(false)
                }
                
                guard let model = response else { return }
                
                if model.statusCode == 0 {
                    let documentStatus = model.data?.documentStatus ?? ""
                    self.dismissActivity()
                    DispatchQueue.main.async {
                        let vc = PaymentsDetailsSuccessViewController()
                        switch documentStatus {
                        case "COMPLETE": self.confurmVCModel?.status = .succses
                        case "IN_PROGRESS": self.confurmVCModel?.status = .inProgress
                        case "REJECTED": self.confurmVCModel?.status = .error
                        default: break
                        }
                        
                        if let closeAction = self.confurmVCModel?.closeAction {
                            
                            vc.closeAction = closeAction
                        }
                        
                        self.confurmVCModel?.paymentOperationDetailId = model.data?.paymentOperationDetailId ?? 0
                        
                        switch self.confurmVCModel?.type {
                        case .card2card:
                            vc.printFormType = "internal"
                            // Template button view model
                            let name = self.confurmVCModel?.cardToRealm?.customName ?? self.confurmVCModel?.cardToRealm?.additionalField ?? "Перевод между счетами"
                            
                            if  let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                            
                        case .phoneNumber:
                            vc.printFormType = "internal"
                            // Template button view model
                            if let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId)
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                            
                        case .requisites:
                            vc.printFormType = "external"
                            // Template button view model
                            if let name = self.confurmVCModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                        case .gkh:
                            vc.printFormType = "housingAndCommunalService"
                        case .mobilePayment:
                            vc.printFormType = "mobile"
                            
                            if let name = self.phoneField.textField.text, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                    
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                        default:
                            break
                        }
                        
                        vc.confurmVCModel = self.confurmVCModel
                        vc.operatorsViewModel = self.operatorsViewModel
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                } else if model.statusCode == 102 {
                    
                    self.doneButtonIsEnabled(false)

                    if let errorMessage = model.errorMessage {
                        
                        self.showAlert(with: "Ошибка", and: errorMessage)
                    }
                    
                } else {

                    self.dismissActivity()
                    self.doneButtonIsEnabled(false)
                    if let errorMessage = model.errorMessage {
                        
                        self.showAlert(with: "Ошибка", and: errorMessage)
                    }
                }
            }
            
        default:
            NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { respons, error in
                self.dismissActivity()
                if error != nil {
                    self.doneButtonIsEnabled(false)
                }
                guard let model = respons else { return }
                
                if model.statusCode == 0 {
                    let documentStatus = model.data?.documentStatus ?? ""
                    DispatchQueue.main.async {
                        let vc = PaymentsDetailsSuccessViewController()
                        switch documentStatus {
                        case "COMPLETED": self.confurmVCModel?.status = .succses
                        case "IN_PROGRESS": self.confurmVCModel?.status = .inProgress
                        case "REJECTED": self.confurmVCModel?.status = .error
                        default: break
                        }
                        self.confurmVCModel?.paymentOperationDetailId = model.data?.paymentOperationDetailId ?? 0
                        switch self.confurmVCModel?.type {
                            
                        case .requisites:
                            vc.printFormType = "external"
                            
                        case .mig:
                            vc.printFormType = "direct"
                            // Template button view model
                            if let name = self.confurmVCModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                        case .contact:
                            vc.printFormType = "contactAddressless"
                            // Template button view model
                            if let name = self.confurmVCModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                        case .phoneNumberSBP:
                            vc.printFormType = "sbp"
                            
                            // Template button view model
                            
                            if let name = self.confurmVCModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                                if self.confurmVCModel?.template == nil {
                                    self.confurmVCModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                } else {
                                    self.confurmVCModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                                }
                            }
                            
                        default:
                            break
                        }
                        
                        vc.confurmVCModel = self.confurmVCModel
                        vc.operatorsViewModel = self.operatorsViewModel
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else if model.statusCode == 102 {
                    self.doneButtonIsEnabled(false)

                    if let errorMessage = model.errorMessage {
                        
                        self.showAlert(with: "Ошибка", and: errorMessage)
                    }
                    
                } else {
                    self.doneButtonIsEnabled(false)
                    if let errorMessage = model.errorMessage {
                        
                        self.showAlert(with: "Ошибка", and: errorMessage)
                    }
                }
            }
        }
    }
    
    // ЖКХ
    func paymentGKH(completion: @escaping (_ error: String?) -> ()) {
        let am = confurmVCModel?.gkhModel?.amount ?? ""
        let pr = confurmVCModel?.gkhModel?.gkhPuref ?? ""
        let bodyArr = confurmVCModel?.gkhModel?.bodyArray ?? [[:]]
        let cardId = confurmVCModel?.cardFromCardId ?? ""
        let cardAccuntId = confurmVCModel?.cardToAccountId ?? ""
        
        let body = [ "check" : false,
                     "amount" : am,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : cardId,
                                 "cardNumber" : nil,
                                 "accountId" : cardAccuntId ],
                     "puref" : pr,
                     "additional" : bodyArr] as [String: AnyObject]
        
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createServiceTransfer, [:], body) { respModel, error in
            if error != nil {
                completion(error!)
                self.showAlert(with: "Ошибка", and: "Техническая ошибка. Попробуйте еще раз")
            } else {
                completion(nil)
            }
        }
    }
}

extension ConfirmViewControllerModel {
    
    enum TemplateButtonViewModel {
        
        case template(PaymentTemplateData.ID)
        case sfp(name: String, paymentOperationDetailId: Int)
    }
}

