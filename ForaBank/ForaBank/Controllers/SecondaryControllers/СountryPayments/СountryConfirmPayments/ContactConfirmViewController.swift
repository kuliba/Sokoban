//
//  ContactConfurmViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 30.05.2021.
//

import UIKit
import RealmSwift
import SwiftUI
import Combine

//TODO: отрефакторить под сетевые запросы, вынести в отдельный файл
class ConfirmViewControllerModel {
    
    static var svgIcon = ""
    lazy var realm = try? Realm()
    var type: PaymentType
    var paymentSystem: PaymentSystemList?
    
    var cardFromRealm: UserAllCardsModel? {
        didSet {
            guard let cardFrom = cardFromRealm else { return }
            if cardFrom.productType == "CARD" {
                cardFromCardId = "\(cardFrom.id)"
                cardFromAccountId = ""
            } else if cardFrom.productType == "ACCOUNT" {
                cardFromAccountId = "\(cardFrom.id)"
                cardFromCardId = ""
            }
//            else if cardFrom.productType == "DEPOSIT" {
//                cardFromAccountId = "\(cardFrom.accountID)"
//                cardFromCardId = ""
//            }
            
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
    var summTransction: String = ""
    var taxTransction: String = ""
    var currancyTransction: String = ""
    var statusIsSuccses: Bool = false
    var summInCurrency = ""
    
    init(type: PaymentType) {
        self.type = type
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
    }
}

class ContactConfurmViewController: UIViewController {
    lazy var realm = try? Realm()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doneButton.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setOtpCode(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)
        let delegate = ContentViewDelegate()
        let statusValue = createTransferSBP?.data?.additionalList?.filter({$0.fieldName == "AFResponse"})
        if statusValue?[0].fieldValue == "G"{
        
        } else {
            guard let data = self.createTransferSBP else {
                return
            }
            self.presentSwiftUIView(data: AntifraudViewModel(model: data, phoneNumber: self.phoneField.text))

        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("dismissSwiftUI"), object: nil, queue: nil) { data in
            let vc = PaymentsDetailsSuccessViewController()
            vc.modalPresentationStyle = .fullScreen
    //            vc.confurmView.operatorImageView = ""
            vc.confurmView.statusImageView.image = UIImage(named: "waiting")
            vc.confurmView.summLabel.text = self.summTransctionField.text
            vc.confurmView.statusLabel.text = "Перевод отменен!"
            vc.confurmView.operatorImageView.image = UIImage(named: "sbp-long")
            vc.confurmView.statusLabel.textColor = .red
            vc.confurmView.buttonsView.isHidden = true
            if data.userInfo?.count ?? 0 > 0{
                vc.confurmView.infoLabel.text = "Время на подтверждение\n перевода вышло"
            } else {
                vc.confurmView.infoLabel.text = ""
            }

            self.present(vc, animated: true, completion: nil)
        }
    }
    

    
    
    @objc func setOtpCode(_ notification: NSNotification) {
        let otpCode = notification.userInfo?["body"] as! String
        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
        smsCodeField.text =  self.otpCode
        
    }
    
    
    func presentSwiftUIView(data: AntifraudViewModel) {
        let swiftUIView = AntifraudView(data: data, delegate: ContentViewDelegate())
        let hostingController = UIHostingController(rootView: swiftUIView)
//        hostingController.modalPresentationStyle = .overCurrentContext
        
        if #available(iOS 15.0, *) {
            if let presentationController = hostingController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()] /// set here!
            }
        } else {
            // Fallback on earlier versions
        }
            hostingController.rootView.present = {
            let vc = PaymentsDetailsSuccessViewController()
            hostingController.present(vc, animated: true, completion: nil)
          }
            present(hostingController, animated: true, completion: nil)

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
        case .openDeposit:
            cardToField.isHidden = true
            taxTransctionField.isHidden = true
            currTransctionField.isHidden = true
            currancyTransctionField.isHidden = true
            smsCodeField.isHidden = true
            
            phoneField.isHidden = false
            phoneField.viewModel.title = "Наименования вклада"
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
            cardFromField.choseButton.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            cardFromField.leftTitleAncor.constant = 64
            cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            cardFromField.model = model.cardFromRealm
            
        case .card2card:
            nameField.isHidden = true
            numberTransctionField.isHidden = true
            phoneField.isHidden = true
            bankField.isHidden = true
            countryField.isHidden = true
            currancyTransctionField.isHidden = true
            
            cardFromField.isHidden = false
            cardFromField.choseButton.isHidden = true
            cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            cardFromField.balanceLabel.isHidden = true
            cardFromField.leftTitleAncor.constant = 64
            
            var fromTitle = "Откуда"
            if let cardModelFrom = model.cardFrom {
                cardFromField.cardModel = cardModelFrom
                if cardModelFrom.productType == "CARD" {
                    fromTitle = "С карты"
                } else if cardModelFrom.productType == "ACCOUNT" {
                    fromTitle = "Со счета"
                }
            } else {
                if model.cardFromCardId != "" || model.cardFromAccountId != "" {
                    let cardList = self.realm?.objects(UserAllCardsModel.self)
                    let cards = cardList?.compactMap { $0 } ?? []
                    cards.forEach({ card in
                        if String(card.id) == model.cardFromCardId || String(card.id) == model.cardFromAccountId {
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
            cardFromField.titleLabel.text = fromTitle
            
            
            cardToField.isHidden = false
            cardToField.choseButton.isHidden = true
            cardToField.balanceLabel.isHidden = true
            cardToField.leftTitleAncor.constant = 64
            
            var toTitle = "Куда"
            
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
                if model.cardToCardId != "" || model.cardToAccountId != "" {
                    let cardList = self.realm?.objects(UserAllCardsModel.self)
                    let cards = cardList?.compactMap { $0 } ?? []
                    cards.forEach({ card in
                        if String(card.id) == model.cardToCardId || String(card.id) == model.cardToAccountId {
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
            
            cardToField.titleLabel.text = toTitle
            
            if !model.summInCurrency.isEmpty {
                currTransctionField.isHidden = false
            }
            currTransctionField.text = model.summInCurrency
            
            
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
                
                if let paymentSystems = Dict.shared.paymentList{
                
                    for system in paymentSystems{
                        if system.code == "SFP"{
                            sbpimage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
                        }
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
            cardFromField.choseButton.isHidden = true
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
            cardFromField.choseButton.isHidden = true
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
            }
            currTransctionField.text = model.summInCurrency
            
            
        case .gkh:
            self.dismissActivity()
            cardFromField.cardModel = model.cardFrom
            cardFromField.isHidden = false
            cardFromField.choseButton.isHidden = true
            cardFromField.balanceLabel.isHidden = true
            cardFromField.titleLabel.text = "Счет списания"
            cardFromField.leftTitleAncor.constant = 64
//            paymentGKH() { error in
//                print("ЖКХ", error ?? "")
//            }
            
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
            }
            currTransctionField.text = model.summInCurrency
            currancyTransctionField.text = model.currancyTransction
            
            let customViewItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "Vector")))
            self.navigationItem.rightBarButtonItem = customViewItem
            
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
            arrangedSubviews: [phoneField,
                               nameField,
                               bankField,
                               countryField,
                               numberTransctionField,
                               cardFromField,
                               cardToField,
                               summTransctionField,
                               taxTransctionField,
                               currTransctionField,
                               currancyTransctionField,
                               smsCodeField])
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
        
        case .card2card, .requisites, .phoneNumber, .gkh, .mobilePayment:
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
                        self.confurmVCModel?.statusIsSuccses = true
                        vc.confurmVCModel = self.confurmVCModel
                        //vc.confurmVCModel?.statusIsSuccses = true
                        vc.id = model.data?.paymentOperationDetailId ?? 0
                        switch self.confurmVCModel?.type {
                        case .card2card, .phoneNumber:
                            vc.printFormType = "internal"
                        case .requisites:
                            vc.printFormType = "external"
                        case .gkh:
                            vc.printFormType = "housingAndCommunalService"
                        case .mobilePayment:
                            vc.printFormType = "mobile"
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
            NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { respons, error in
                self.dismissActivity()
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                    self.showAlert(with: "Ошибка", and: error ?? "")
                }
                guard let model = respons else { return }
                
                if model.statusCode == 0 {
                    print("DEBUG: Success payment")
                    DispatchQueue.main.async {
                        let vc = PaymentsDetailsSuccessViewController()
                        vc.confurmVCModel = self.confurmVCModel
                        vc.confurmVCModel?.statusIsSuccses = true
                        vc.id = model.data?.paymentOperationDetailId ?? 0
                        switch self.confurmVCModel?.type {
                        case .card2card, .phoneNumber:
                            vc.printFormType = "internal"
                        case .requisites:
                            vc.printFormType = "external"
                        default:
                            break
                        }
                        if self.confurmVCModel?.type == .phoneNumberSBP {
                            vc.printFormType = "sbp"
                        }
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                } else if model.statusCode == 102 {
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
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
//            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ContaktPaymentBegin ", error ?? "")
                completion(error!)
            } else {
                completion(nil)
            }
        }
    }

}

