//
//  PaymentByPhoneViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit
import RealmSwift
import AnyFormatKit
import SwiftUI
import IQKeyboardManagerSwift

class PaymentByPhoneViewController: UIViewController, UITextFieldDelegate {
    
    var viewModel: PaymentByPhoneViewModel
    let model: Model = .shared
    
    var banks: [BanksList]? {
        didSet {
            guard let banks = banks else { return }
            bankListView.bankList = banks
        }
    }
    
    //MARK: - Views
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
    
    var cardListView = CardsScrollView(onlyMy: true, deleteDeposit: true)
    
    var bottomView = BottomInputView()
    
    var selectNumber: String?
    //MARK: - Viewlifecicle
    
    init(viewModel: PaymentByPhoneViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneField.textField.delegate = self
        phoneField.textField.maskString = "+0 000 000-00-00"
        
        phoneField.rightButton.setImage(UIImage(named: "user-plus"), for: .normal)
        
        if let maskPhoneNumber = viewModel.maskPhoneNumber {
            phoneField.text = maskPhoneNumber
            selectNumber = maskPhoneNumber
        }
        
        setupUI()
        
        self.cardField.model = viewModel.userCard
        
        setupBankList()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let template = viewModel.template {
            runBlockAfterDelay(0.2) {
                self.setupAmount(amount: template.amount)
                self.bottomView.doneButtonIsEnabled(false)
                self.bottomView.doneButton.isEnabled =  true
            }
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Helpers
    
    func setupAmount(amount: Double?) {
        guard let moneyFormatter = bottomView.moneyFormatter else { return }
        let newText = moneyFormatter.format("\(viewModel.amount ?? 0)") ?? ""
        bottomView.amountTextField.text = newText
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            viewModel.phoneNumber = updatedText
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
        
        var filteredbanksList : [BanksList] = []
        
        model.dictionaryBankListLegacy?.forEach { bank in
            let codeList = bank.paymentSystemCodeList
            codeList?.forEach { code in
                if code == "SFP" {
                    filteredbanksList.append(bank)
                }
            }
        }
        self.banks = filteredbanksList
        
    }
    
    func setupActions() {
        cardField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                
                var products: [UserAllCardsModel] = []
                
                let data = self.model.products.value
                
                products = data.flatMap({$0.value}).compactMap({$0.userAllProducts()})
                
                products.forEach({ card in
                    if card.id == cardId {
                        self.cardField.model = card
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
        
        bankListView.didBankTapped = { bank in
            self.viewModel.bankId = bank.memberID ?? ""
            self.setupBankField(bank: self.viewModel.selectedBank)
            self.hideView(self.bankListView, needHide: true)
        }
        
        phoneField.didChooseButtonTapped = {() in
            let contactPickerScene = EPContactsPicker(
                delegate: self,
                multiSelection: false,
                subtitleCellType: SubtitleCellValue.phoneNumber)
            self.present(contactPickerScene, animated: true, completion: nil)
        }
        
        bottomView.didDoneButtonTapped = {(amount) in
            switch self.viewModel.isSbp {
            case true:
                self.startContactPayment(with: self.cardField.model, amount: amount) { [self] error in
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    }
                }
            default:
                self.createTransfer(amount: amount, card: self.cardField.model) { [self] error in
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    }
                }
            }
        }
    }
    
    fileprivate func setupUI() {
        
        if selectNumber != nil {
            phoneField.textField.text = selectNumber ?? ""
            phoneField.textField.maskString = selectNumber ?? ""
        }
        view.backgroundColor = .white
        
        cardField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardField.imageView.isHidden = false
        cardField.leftTitleAncor.constant = 64
        
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        
        view.addSubview(saveAreaView)
        saveAreaView.anchor(
            top: view.safeAreaLayoutGuide.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        view.addSubview(bottomView)
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        bottomView.currencySymbol = "₽"
        
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
        
        let paymentSystems = Model.shared.paymentSystemList.value.map { $0.getPaymentSystem() }
        
        for system in paymentSystems {
            if system.code == "SFP" {
                sbpimage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
            }
        }
        
        if let template = viewModel.template {
            title = template.name
            let button = UIBarButtonItem(image: UIImage(named: "edit-2"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(updateNameTemplate))
            button.tintColor = .black
            navigationItem.rightBarButtonItem = button
            
            let backButton = UIBarButtonItem(image: UIImage(named: "back_button"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(onTouchBackButton))
            backButton.tintColor = .black
            navigationItem.leftBarButtonItem = backButton
            
        } else {
            if viewModel.isSbp {
                title = "Перевод через СБП"
                let imageView = UIImageView(image: sbpimage)
                let item = UIBarButtonItem(customView: imageView)
                imageView.contentMode = .scaleAspectFit
                imageView.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
                self.navigationItem.rightBarButtonItem = item
            } else {
                title = "Перевод по номеру телефона"
            }
            
            let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(onTouchBackButton))
            button.tintColor = .black
            navigationItem.leftBarButtonItem = button
        }
        setupBankField(bank: viewModel.selectedBank)
    }
    
    @objc func onTouchBackButton() {
        viewModel.closeAction()
        dismiss(animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupBankField(bank: BanksList?) {
        self.bankPayeer.text = bank?.memberNameRus ?? ""
        self.viewModel.bankId = bank?.memberID ?? ""
        self.bankPayeer.imageView.image = bank?.svgImage?.convertSVGStringToImage()
    }
    
    @objc private func updateNameTemplate() {
        self.showInputDialog(title: "Название шаблона",
                             actionTitle: "Сохранить",
                             cancelTitle: "Отмена",
                             inputText: viewModel.template?.name,
                             inputPlaceholder: "Введите название шаблона",
                             actionHandler:  { text in
            
            guard let text = text else { return }
            guard let templateId = self.viewModel.template?.paymentTemplateId else { return }
            
            if text.isEmpty != true {
                if text.count < 20 {
                    Model.shared.action.send(ModelAction.PaymentTemplate.Update.Requested(
                        name: text,
                        parameterList: nil,
                        paymentTemplateId: templateId))
                    
                    // FIXME: В рефактре нужно слушатель на обновление title
                    self.parent?.title = text
                    
                } else {
                    self.showAlert(with: "Ошибка", and: "В названии шаблона не должно быть более 20 символов")
                }
            } else {
                self.showAlert(with: "Ошибка", and: "Название шаблона не должно быть пустым")
            }
        })
    }
    
    //MARK: - API
    
    func getBankList(completion: @escaping (_ banksList: [BanksList]?, _ error: String?) -> () ) {
        guard let banks = Model.shared.dictionaryBankListLegacy else {
            return completion(nil, "Не удалось загрузить список банков")
        }
            
        completion(banks, nil)
    }
    
    func createTransfer(amount: String, card: UserAllCardsModel?, completion: @escaping (_ error: String?) -> ()) {
        self.dismissKeyboard()
        self.showActivity()
        
        guard let number = phoneField.textField.unmaskedText else { return }
        guard let comment = commentField.textField.text else { return }
        
        bottomView.doneButtonIsEnabled(true)
        
        let body = [ "check"            : false,
                     "amount"           : amount,
                     "comment"          : comment,
                     "currencyAmount"   : "RUB",
                     "payer" : [
                        "cardId"        : card?.productType == "CARD" ? (card?.id ?? 0) : nil,
                        "cardNumber"    : nil,
                        "accountId"     : card?.productType == "ACCOUNT" ? (card?.id ?? 0) : nil,
                        "accountNumber" : nil
                     ],
                     "payeeInternal" : [
                        "cardId"        : nil,
                        "cardNumber"    : nil,
                        "accountId"     : nil,
                        "accountNumber" : nil,
                        "phoneNumber"   : number,
                        "productCustomName" : nil
                     ] ] as [String : AnyObject]
        
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] dataresp, error in
            
            DispatchQueue.main.async {
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if dataresp?.errorMessage != nil {
                    completion(dataresp?.errorMessage)
                } else {
                    guard let data = dataresp?.data else { return }
                    guard let statusCode = dataresp?.statusCode else { return }
                    if statusCode == 0 {
                        DispatchQueue.main.async {
                            let model = ConfirmViewControllerModel(type: .phoneNumber, status: .succses)
                            model.bank = self?.viewModel.selectedBank
                            model.cardFromRealm = self?.cardField.model
                            model.phone = self?.phoneField.textField.unmaskedText
                            model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                            model.summInCurrency = data.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                            model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                            model.fullName = data.payeeName ?? "Получатель не определен"
                            model.status = .succses
                            model.template = self?.viewModel.template
                            
                            let vc = ContactConfurmViewController()
                            vc.getUImage = { self?.model.images.value[$0]?.uiImage }
                            vc.confurmVCModel = model
                            vc.title = "Подтвердите реквизиты"
                            vc.addCloseButton()
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                            self?.present(navController, animated: true, completion: nil)
                        }
                    } else {
                        completion(dataresp?.errorMessage)
                    }
                }
            }
        }
    }
    
    func startContactPayment(with card: UserAllCardsModel?, amount: String, completion: @escaping (_ error: String?) -> () ) {
        
        guard let number = phoneField.textField.unmaskedText else { return }
        guard let comment = commentField.textField.text else { return }
        showActivity()
        
        let newBody = [
            "check" : false,
            "amount" : amount,
            "currencyAmount" : "RUB",
            "payer" : [
                "cardId" : card?.productType == "CARD" ? (card?.id ?? 0) : nil,
                "cardNumber" : nil,
                "accountId" : card?.productType == "ACCOUNT" ? (card?.id ?? 0) : nil
            ],
            "puref" : "iFora||TransferC2CSTEP",
            "additional" : [
                [
                    "fieldid": "1",
                    "fieldname": "RecipientID",
                    "fieldvalue": number
                ],
                [
                    "fieldid": "2",
                    "fieldname": "BankRecipientID",
                    "fieldvalue": viewModel.bankId
                ],
                [
                    "fieldid": "3",
                    "fieldname": "Ustrd",
                    "fieldvalue": comment
                ]
            ]
        ] as [String: AnyObject]
        
        NetworkManager<CreateSFPTransferDecodableModel>.addRequest(.createSFPTransfer, [:], newBody, completion: { [weak self] data, error in
            self?.dismissActivity()
            if data?.errorMessage != nil {
                completion(error)
            }
            guard let data = data else { return }
            if data.statusCode == 0 {
                DispatchQueue.main.async {
                    let model = ConfirmViewControllerModel(type: .phoneNumberSBP, status: .succses)
                    if self?.viewModel.selectedBank != nil {
                        model.bank = self?.viewModel.selectedBank
                    }
                    model.cardFromRealm = self?.cardField.model
                    model.phone = self?.phoneField.textField.unmaskedText
                    model.fullName = data.data?.payeeName
                    model.summTransction = Double(data.data?.amount ?? Double(0.0)).currencyFormatter(symbol: data.data?.currencyAmount ?? "" )
                    model.taxTransction = data.data?.fee?.currencyFormatter(symbol: data.data?.currencyAmount ?? "") ?? ""
                    model.comment = self?.commentField.textField.text ?? ""
                    model.status = .succses
                    model.template = self?.viewModel.template
                    
                    let statusValue = data.data?.additionalList?.filter({$0.fieldName == "AFResponse"})
                    let numberTransaction = data.data?.additionalList?.filter({$0.fieldName == "BizMsgIdr"})
                    
                    let vc = ContactConfurmViewController()
                    vc.getUImage = { self?.model.images.value[$0]?.uiImage }
                    vc.confurmVCModel = model
                    if numberTransaction?.count ?? 0 > 0{
                        vc.confurmVCModel?.numberTransction = numberTransaction?[0].fieldValue?.description ?? ""
                    }
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
                }
            } else {
                completion(data.errorMessage)
            }
        })
    }
    
    //MARK: - Animation
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
}

//MARK: EPContactsPicker delegates
extension PaymentByPhoneViewController: EPPickerDelegate {
    
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError) {}
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError) {}
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {}
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact) {
        let phoneFromContact = contact.phoneNumbers.first?.phoneNumber
        var numbers = phoneFromContact?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if numbers?.first == "7" {
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            viewModel.phoneNumber = maskPhone ?? ""
        } else if numbers?.first == "8" {
            numbers?.removeFirst()
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            viewModel.phoneNumber = maskPhone ?? ""
        }
    }
    
    func epUserPhone(_ phone: String) {
        var numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if numbers.first == "7" {
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            phoneField.textField.text = maskPhone ?? ""
            selectNumber = maskPhone ?? ""
        } else if numbers.first == "8" {
            numbers.removeFirst()
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            phoneField.textField.text = maskPhone ?? ""
            selectNumber = maskPhone ?? ""
        }
    }
    
}
