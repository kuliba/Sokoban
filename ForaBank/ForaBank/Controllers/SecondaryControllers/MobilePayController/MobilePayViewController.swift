//
//  MobilePayViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

class MobilePayViewController: UIViewController, UITextFieldDelegate {
    
    let model = Model.shared
    var operatorsViewModel: OperatorsViewModel?
    var viewModel: MobilePayViewModel? = nil
    var recipiendId = String()
    var phoneNumber: String?
    var regEx = ""
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: UIImage(named: "smartphonegray")!,
            showChooseButton: true)
    )
    
    var cardField = CardChooseView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    var cardListView = CardsScrollView(onlyMy: true, deleteDeposit: true)
    
    var bottomView = BottomInputView()
    
    var selectNumber: String?
    var paymentTemplate: PaymentTemplateData? = nil
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(paymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = paymentTemplate
        
        if let model = paymentTemplate.parameterList.first as? TransferAnywayData {
            
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            let phone = model.additional.first(where: { $0.fieldname == "a3_NUMBER_1_2" })
            let maskPhone = mask.mask(string: phone?.fieldvalue)
            
            selectNumber = maskPhone
            phoneField.textField.text = maskPhone
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        setupActions()
        cardField.model = getUserCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
        if let template = paymentTemplate {
            runBlockAfterDelay(0.2) {
                
                self.setupAmount(amount: template.amount)
            }
        }
    }
    
    private func getUserCard() -> UserAllCardsModel?  {
        let productTypes: [ProductType] = [.card, .account]
        
        let allCards = ReturnAllCardList.cards()
        var productsFilterredMapped = [UserAllCardsModel]()
        
        productTypes.forEach { type in
            
            productsFilterredMapped += allCards.filter { $0.productType == type.rawValue && $0.currency == "RUB" }
        }
        
        if productsFilterredMapped.count > 0 {
            if let template = self.paymentTemplate,
               let transfer = template.parameterList.first as? TransferAnywayData,
               let cardId = transfer.payer?.cardId {
                
                let card = productsFilterredMapped.first(where: { $0.id == cardId })
                return card
                
            } else {
                return productsFilterredMapped.first
            }
        }
        return nil
    }
    
    func setupAmount(amount: Double?) {
        guard let moneyFormatter = bottomView.moneyFormatter else { return }
        let newText = moneyFormatter.format("\(amount ?? 0)") ?? ""
        bottomView.amountTextField.text = newText
        bottomView.doneButtonIsEnabled(newText.isEmpty)
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
    
    func setupActions() {
        
        cardField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                
                let products = self.model.products.value.values.flatMap({ $0 }).map { $0.userAllProducts() }
                
                products.forEach({ card in
                    if card.id == cardId {
                        self.cardField.model = card
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                    }
                })
            }
        }
        
        
        cardListView.lastItemTap = {
            let vc = AllCardListViewController()
            vc.withTemplate = false
            vc.didCardTapped = { card in
                self.cardField.model = card
                //                self.selectedCardNumber = card.cardID ?? 0
                self.hideView(self.cardListView, needHide: true)
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
        
        phoneField.didChooseButtonTapped = {() in
            let contactPickerScene = EPContactsPicker(
                delegate: self,
                multiSelection: false,
                subtitleCellType: SubtitleCellValue.phoneNumber)
            
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            navigationController.modalPresentationStyle = .automatic
            self.present(navigationController, animated: true, completion: nil)
        }
        
        bottomView.didDoneButtonTapped = { [self](amount) in
            /// Вызвать правильный метод оплаты
            self.startContactPayment(with: selectNumber ?? "", amount: amount) { [weak self] error in
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
            }
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
    
    
    fileprivate func setupUI() {
        title = "Мобильная связь"
        
        if let paymentTemplate = paymentTemplate {
            
            title = paymentTemplate.name
        }
        
        phoneField.textField.delegate = self
        phoneField.rightButton.setImage(UIImage(imageLiteralResourceName: "user-plus"), for: .normal)
        if selectNumber != nil {
            phoneField.textField.text = selectNumber ?? ""
            phoneField.textField.maskString = selectNumber ?? ""
        }
        
        phoneField.textField.maskString = "+7 (000) 000-00-00"
        view.backgroundColor = .white
        
        let saveAreaView = UIView()
        view.addSubview(saveAreaView)
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
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
        
        stackView = UIStackView(arrangedSubviews: [phoneField, cardField, cardListView])
        view.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20)
        
    }
    
    //MARK: - API
    
    ///  Запрос на перевод по мобильной связи
    func startContactPayment(with phone: String, amount: String, completion: @escaping (_ error: String?) -> () ) {
        showActivity()
        
        let newBody = [ "phoneNumbersList" : [phone.digits] ] as [String: AnyObject]
        
        NetworkManager<GetPhoneInfoDecodableModel>.addRequest(.getPhoneInfo, [:], newBody, completion: { [weak self] phoneData, error in
            
            if phoneData?.errorMessage != nil {
                self?.dismissActivity()
                completion(error)
            }
            
            guard let data = phoneData else { return }
            
            if phoneData?.statusCode == 0 {
                UserDefaults.standard.set(data.data?.first?.svgImage, forKey: "MobilePhoneSVGImage")
                let puref = data.data?.first?.puref ?? ""
                let svgImage = data.data?.first?.svgImage
                let cardId = self?.cardField.model?.id ?? 0
                
                var phoneFormate = phone.digits
                phoneFormate.removeFirst()
                
                let body = [
                    "check" : false,
                    "amount" : amount,
                    "currencyAmount" : "RUB",
                    "payer" : [
                        "cardId" : cardId,
                        "cardNumber" : nil,
                        "accountId" : nil
                    ],
                    "puref" : puref,
                    "additional" : [[
                        "fieldid": 1,
                        "fieldname": "a3_NUMBER_1_2",
                        "fieldvalue": phoneFormate]]
                ] as [String: AnyObject]
                
                NetworkManager<CreateMobileTransferDecodableModel>.addRequest(.createMobileTransfer, [:], body, completion: { [weak self] data, error in
                    
                    self?.dismissActivity()
                    if data?.errorMessage != nil {
                        completion(error)
                    }
                    
                    if data?.statusCode == 102 {
                        self?.showAlert(with: "Ошибка", and: data?.errorMessage ?? "")
                        completion("")
                        return
                    }
                    
                    if data?.statusCode == 0 {
                        let model = ConfirmViewControllerModel(type: .mobilePayment, status: .succses)
                        model.operatorImage = svgImage ?? ""
                        model.cardFromRealm = self?.cardField.model
                        
                        if let closeAction = self?.viewModel?.closeAction {
                            
                            model.closeAction = closeAction
                        }
                        let a = data?.data?.additionalList
                        
                        a?.forEach{ list in
                            if list.fieldName == "a3_NUMBER_1_2" {
                                model.phone = list.fieldValue
                            }
                        }
                        
                        model.summTransction = Double(data?.data?.amount ?? Double(0.0)).currencyFormatter(symbol: "RUB" )
                        model.taxTransction = Double(data?.data?.fee ?? Int(0.0)).currencyFormatter(symbol: "RUB")
                        
                        model.status = .succses
                        DispatchQueue.main.async {
                            let vc = ContactConfurmViewController()
                            vc.getUImage = { self?.model.images.value[$0]?.uiImage }
                            vc.confurmVCModel = model
                            vc.addCloseButton()
                            vc.title = "Подтвердите реквизиты"
                            vc.operatorsViewModel = self?.operatorsViewModel
                            vc.confurmVCModel?.template = self?.paymentTemplate
                            if let viewModel = self?.viewModel {
                                
                                vc.operatorsViewModel?.closeAction = viewModel.closeAction
                            }
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                            self?.present(navController, animated: true, completion: nil)
                            
                        }
                    }
                })
            } else {
                
                completion(data.errorMessage)
            }
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
    }
    
}

extension MobilePayViewController: EPPickerDelegate {
    
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError) {
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact) {
        let phoneFromContact = contact.phoneNumbers.first?.phoneNumber
        var numbers = phoneFromContact?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if numbers?.first == "7" {
            let mask = StringMask(mask: "+0 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            phoneField.textField.text = maskPhone ?? ""
            selectNumber = maskPhone ?? ""
        } else if numbers?.first == "8" {
            numbers?.removeFirst()
            let mask = StringMask(mask: "+7 (000) 000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
            phoneField.textField.text = maskPhone ?? ""
            selectNumber = maskPhone ?? ""
        }
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError) {
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        for contact in contacts {
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
    
    func isValidPassword(_ input: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", self.regEx).evaluate(with: input)
    }
    
}
