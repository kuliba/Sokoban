//
//  PaymentByPhoneViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit
import RealmSwift
import SwiftUI

class PaymentByPhoneViewController: UIViewController, UITextFieldDelegate {

    lazy var realm = try? Realm()

    var sbp: Bool?
    var confirm: Bool?
    var selectedCardNumber = 0
    var selectedAccountId = 0
    var productType = ""
    var cardIsSelect = false

    var selectedBank: BanksList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }
    var bankId = String()
    var banks: [BanksList]? {
        didSet {
            guard let banks = banks else { return }
            bankListView.bankList = banks
        }
    }
    var recipiendId = String()
    var phoneNumber: String?
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: UIImage(named: "smartphonegray")!,
            showChooseButton: true)
    )
    
    var cardField = CardChooseView()
    
    var bankPayeer = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false,
            showChooseButton: true)
    )
    
    var bankListView = BankListView()
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: true)
    )
    
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: UIImage(named: "hash")!,
            isEditable: false)
    )
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: UIImage(named: "coins")!,
            isEditable: true)
    )
    
    var commentField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сообщение получателю",
            image: #imageLiteral(resourceName: "message"),
            isEditable: true)
    )
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false)
    )
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: UIImage(named: "message-square")!,
            type: .smsCode)
    )
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    var cardListView = CardsScrollView(onlyMy: true)
    
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
//        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var bottomView = BottomInputView()
    
    var otpCode: String?
    
    var selectNumber: String?
//    var memberId: String?
    
    @objc func showSpinningWheel(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        let otpCode = notification.userInfo?["body"] as! String
        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AddAllUserCardtList.add() {
           print(" AddAllUserCardtList.add()")

        }
        
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "otpCode"))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)

  
        phoneField.rightButton.setImage(UIImage(imageLiteralResourceName: "user-plus"), for: .normal)
        if selectNumber != nil{
            phoneField.text = selectNumber ?? ""
        }
        view.addSubview(bottomView)
        setupUI()
        
        phoneField.textField.delegate = self
        phoneField.textField.maskString = "0 (000) 000-00-00"
        
        
        phoneField.didChooseButtonTapped = {() in
            
            let contactPickerScene = EPContactsPicker(
                delegate: self,
                multiSelection: false,
                subtitleCellType: SubtitleCellValue.phoneNumber)
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            self.present(navigationController, animated: true, completion: nil)
            
            
        }
        
        setupActions()
        
        bottomView.didDoneButtonTapped = {(amount) in
            switch self.sbp{
            case true:
                self.startContactPayment(with: self.selectedCardNumber) { [self] error in
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    } else {

                    }
                }
            default:
                self.createTransfer()
            }
        }
        
        DispatchQueue.main.async {
            var filterProduct: [UserAllCardsModel] = []
            let cards = ReturnAllCardList.cards()
            cards.forEach { product in
                if (product.productType == "CARD"
                        || product.productType == "ACCOUNT") && product.currency == "RUB" {
                    filterProduct.append(product)
                }
            }
            
            if filterProduct.count > 0 {
                self.cardField.model = filterProduct.first
                guard let cardId  = filterProduct.first?.cardID else { return }
                guard let accountId  = filterProduct.first?.id else { return }
                if filterProduct.first?.productType == "ACCOUNT"{
                    self.selectedAccountId = accountId
                } else {
                    self.selectedCardNumber = cardId
                }
                self.productType = filterProduct.first?.productType ?? ""

                self.cardIsSelect = true
            }
        }
        
        setupBankList()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            selectNumber = updatedText
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let textField = textField as? MaskedTextField {
            let text = textField.unmaskedText ?? ""
            bottomView.amountTextField.isEnabled = text.count < 11 ? false : true
            bottomView.doneButton.isEnabled = text.count < 11 ? true : false
            bottomView.doneButtonIsEnabled(text.count < 11 ? true : false)
        }
    }
    
    func setupBankList() {
        getBankList { [weak self]  banksList, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                
                guard let banksList = banksList else { return }
                var filteredbanksList : [BanksList] = []
                
                banksList.forEach { bank in
                    guard let codeList = bank.paymentSystemCodeList else { return }
                    codeList.forEach { code in
                        if code == "SFP" {
                            filteredbanksList.append(bank)
                        }
                    }
                }
                self?.banks = filteredbanksList
            }
        }
        
        bankListView.didBankTapped = { bank in
            self.selectedBank = bank
            self.bankId = bank.memberID ?? ""
            if bank.memberID == "100000000217"{
                self.sbp = false
            } else {
                self.sbp = true
            }
            self.hideView(self.bankListView, needHide: true)
        }
    }
    
    func setupActions() {
        cardField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }
        
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {

                
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.cardField.model = card
                      
                        if card.productType == "ACCOUNT"{
                            self.selectedAccountId = card.id
                        } else {
                            self.selectedCardNumber = card.cardID
                        }
                        self.productType = card.productType ?? ""
                        if self.bankListView.isHidden == false {
                            self.hideView(self.bankListView, needHide: true)
                        }
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                    }
                })
            }
                      
        }
        bankPayeer.didChooseButtonTapped = { () in
            self.openOrHideView(self.bankListView)
            
        }
    }
    
    private func openOrHideView(_ view: UIView) {
        UIView.animate(withDuration: 0.2) {
            if view.isHidden == true {
                view.alpha = 1
                view.isHidden = false
                
            } else {
                view.alpha = 0
                view.isHidden = true
            }
            
            self.stackView.layoutIfNeeded()
        }
    }
    
    private func hideView(_ view: UIView, needHide: Bool) {
        UIView.animate(withDuration: 0.2) {
            view.alpha = needHide ? 0 : 1
            view.isHidden = needHide
            self.stackView.layoutIfNeeded()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        
        
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        bottomView.currencySymbol = "₽"


            
        title = "Перевод по номеру телефона"
        stackView = UIStackView(arrangedSubviews: [phoneField, bankPayeer, bankListView, cardField, cardListView, commentField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        var sbpimage = UIImage()
        
        if let paymentSystems = Dict.shared.paymentList{
        
            for system in paymentSystems{
                if system.code == "SFP"{
                    sbpimage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
                }
            }
            
        }
        
        if sbp ?? false {
            title = "Перевод через СБП"
            
            let imageView = UIImageView(image: sbpimage)
            let item = UIBarButtonItem(customView: imageView)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
            self.navigationItem.rightBarButtonItem = item
            
        }
        
    }
    
    private func setupBankField(bank: BanksList) {
        self.bankPayeer.text = bank.memberNameRus ?? ""
        self.bankId = bank.memberID ?? ""
        self.bankPayeer.imageView.image = bank.svgImage?.convertSVGStringToImage()
    }
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
    }
    
    func getBankList(completion: @escaping (_ banksList: [BanksList]?, _ error: String?)->()) {

        NetworkHelper.request(.getBanks) { banksList , error in
            if error != nil {
                completion(nil, error)
            }
            guard let banksList = banksList as? [BanksList] else { return }
            completion(banksList, nil)
            print("DEBUG: Load Banks List... Count is: ", banksList.count)
        }
    }
    
    func createTransfer() {
        self.dismissKeyboard()
        self.showActivity()
        guard let number = phoneField.textField.unmaskedText else {
            return
        }
        guard let sum = bottomView.amountTextField.text else {
            return
        }
        
        let clearAmount = sum.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "").replacingOccurrences(of: ",", with: ".")
        let clearNumber = number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: "+", with: "")
        var accountNumber: Int?
        var cardId: Int?
        
        if  self.productType == "ACCOUNT"{
            accountNumber = selectedAccountId
        } else {
            cardId = selectedCardNumber
        }

        guard let comment = commentField.textField.text else {
            return
        }
        
        bottomView.doneButtonIsEnabled(true)
        
        let body = [ "check"            : false,
                     "amount"           : clearAmount,
                     "comment"          : comment,
                     "currencyAmount"   : "RUB",
                     "payer" : [
                        "cardId"        : cardId,
                        "cardNumber"    : nil,
                        "accountId"     : accountNumber,
                        "accountNumber" : nil
                     ],
                     "payeeInternal" : [
                        "cardId"        : nil,
                        "cardNumber"    : nil,
                        "accountId"     : nil,
                        "accountNumber" : nil,
                        "phoneNumber"   : clearNumber.description,
                        "productCustomName" : nil
                     ] ] as [String : AnyObject]
        
        print("DEBUG: ", #function, body)
        
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] dataresp, error in
            DispatchQueue.main.async {
                self?.bottomView.doneButtonIsEnabled(false)
                if dataresp?.errorMessage != nil {
                    print("DEBUG: ", #function, dataresp?.errorMessage ?? "")
                    self?.showAlert(with: "Ошибка", and: dataresp?.errorMessage ?? "Ошибка")
                    self?.dismissActivity()
                } else {
                    guard let data = dataresp?.data else { return }
                    guard let statusCode = dataresp?.statusCode else { return }
                    if statusCode == 0 {
                        DispatchQueue.main.async {
                            let model = ConfirmViewControllerModel(type: .phoneNumber)
                            model.bank = self?.selectedBank
                            model.cardFromRealm = self?.cardField.model
                            model.phone = self?.phoneField.textField.text?.digits ?? ""
                            model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                            model.summInCurrency = data.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                            model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                            model.fullName = data.payeeName ?? "Получатель не оперделен"
                            model.status = .succses
                            
                            let vc = ContactConfurmViewController()
                            vc.confurmVCModel = model
                            vc.title = "Подтвердите реквизиты"
                            vc.addCloseButton()
                            self?.dismissActivity()
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                            self?.present(navController, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG: ", #function, dataresp?.errorMessage ?? "nil")
                        self?.dismissActivity()
                        self?.showAlert(with: "Ошибка", and: dataresp?.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
    func startContactPayment(with card: Int, completion: @escaping (_ error: String?)->()) {
        showActivity()
        
        var accountId: Int?
        var cardId: Int?
        
        if productType == "ACCOUNT"{
            accountId = selectedAccountId
        } else {
            cardId = selectedCardNumber
        }
        
        guard let number = phoneField.textField.unmaskedText else {
            return
        }
        
        guard let sum = bottomView.amountTextField.text else {
            return
        }
        
        let clearAmount = sum.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "").replacingOccurrences(of: ",", with: ".")

        var newPhone = String()
        var clearPhone = String()
        
        newPhone = number.digits 
        
        if newPhone.prefix(1) == "7" || newPhone.prefix(1) == "8"{
            clearPhone = String(newPhone.dropFirst())
        } else{
            clearPhone = newPhone
        }
        
        guard let comment = commentField.textField.text else {
            return
        }
        
        let newBody = [
            "check" : false,
            "amount" : clearAmount,
            "currencyAmount" : "RUB",
            "payer" : [
                "cardId" : cardId,
                "cardNumber" : nil,
                "accountId" : accountId
            ],
            "puref" : "iFora||TransferC2CSTEP",
            "additional" : [
                [
                  "fieldid": "1",
                  "fieldname": "RecipientID",
                  "fieldvalue": clearPhone
                ],
                [
                  "fieldid": "2",
                  "fieldname": "BankRecipientID",
                  "fieldvalue": bankId
                ],
                [
                  "fieldid": "3",
                  "fieldname": "Ustrd",
                  "fieldvalue": comment
                ]
            ]
        ] as [String: AnyObject]
        
        NetworkManager<CreateSFPTransferDecodableModel>.addRequest(.createSFPTransfer, [:], newBody, completion: { [weak self] data, error in
           
            if data?.errorMessage != nil {
                    print("DEBUG: Error: ", error ?? "")
                    self?.dismissActivity()
                    self?.showAlert(with: "Ошибка", and: data?.errorMessage ?? "")
                    completion(error)
                }
                guard let data = data else { return }
                if data.statusCode == 0 {
                    print("DEBUG: Success send Phone")
                    self?.confirm = true
                    DispatchQueue.main.async {
                        let model = ConfirmViewControllerModel(type: .phoneNumberSBP)
                        if self?.selectedBank != nil {
                            model.bank = self?.selectedBank
                        } else {
                            
                        }
                        
                        model.cardFromRealm = self?.cardField.model
                        model.phone = self?.phoneField.textField.text?.digits ?? ""
                        model.fullName = data.data?.payeeName
                        model.summTransction = Double(data.data?.amount ?? Double(0.0)).currencyFormatter(symbol: data.data?.currencyAmount ?? "" )
                        model.taxTransction = data.data?.fee?.currencyFormatter(symbol: data.data?.currencyAmount ?? "") ?? ""
                        model.comment = self?.commentField.textField.text ?? ""
                        
                        model.status = .succses
                        let statusValue = data.data?.additionalList?.filter({$0.fieldName == "AFResponse"})
                            
                            let vc = ContactConfurmViewController()
                            vc.confurmVCModel = model
                            vc.addCloseButton()
                            vc.title = "Подтвердите реквизиты"
                            vc.createTransferSBP = data
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                        if statusValue?[0].fieldValue == "G"{
                            self?.present(navController, animated: true, completion: nil)
                        } else {
                            self?.present(navController, animated: true, completion: nil)
                        }
                        self?.dismissActivity()
                        
                    }
                } else {
                    self?.dismissActivity()
                    self?.showAlert(with: "Ошибка", and: data.errorMessage ?? "")
                    print("DEBUG: Error: ", data.errorMessage ?? "")

                    self?.showAlert(with: "Ошибка", and: data.errorMessage ?? "")
                    completion(
                        data.errorMessage)
                }
            
        })
        
        
    }

}

//MARK: EPContactsPicker delegates
extension PaymentByPhoneViewController: EPPickerDelegate {
    
        func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError) {
            print("Failed with error \(error.description)")
        }
        
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact) {
        let phoneFromContact = contact.phoneNumbers.first?.phoneNumber
        var numbers = phoneFromContact?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if numbers?.first == "7" {
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            selectNumber = maskPhone ?? ""
        } else if numbers?.first == "8" {
            numbers?.removeFirst()
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            selectNumber = maskPhone ?? ""
        } else {
            
        }
    }
        
        func epContactPicker(_: EPContactsPicker, didCancel error : NSError) {
            print("User canceled the selection");
        }
        
        func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
            print("The following contacts are selected")
            for contact in contacts {
                print("\(contact.displayName())")
            }
        }

}
