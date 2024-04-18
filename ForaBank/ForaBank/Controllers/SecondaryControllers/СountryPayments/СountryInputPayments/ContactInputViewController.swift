//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import RealmSwift
import PhoneNumberKit
import IQKeyboardManagerSwift

class ContactInputViewController: UIViewController {
    
    let model = Model.shared
    let phoneNumberKit = PhoneNumberKit()
    var operatorsViewModel: OperatorsViewModel?
    var typeOfPay: PaymentType = .contact {
        didSet {
            readAndSetupCard(type: typeOfPay)
        }
    }
    var cardIsSelect = false
    var selectedCardNumber = ""
    var puref = ""
    var currency = "" {
        didSet {
            guard let system = paymentSystem else { return }
            setupCurrencyButton(system: system)
        }
    }
    var paymentTemplate: PaymentTemplateData? = nil
    var trnPickupPoint = ""
    var selectedBank: BanksList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }
    var needShowSwitchView: Bool = false {
        didSet {
            foraSwitchView.isHidden = needShowSwitchView ? false : true
        }
    }
    
    var country: CountriesList? {
        didSet {
            if country?.code == "AM" {
                self.typeOfPay = .mig
                self.configure(with: country, byPhone: true)
            } else {
                self.typeOfPay = .contact
                self.configure(with: country, byPhone: false)
            }
        }
    }
    
    var banks: [BanksList]? {
        didSet {
            guard let banks = banks else { return }
            bankListView.bankList = banks
        }
    }
    
    var paymentSystem: PaymentSystemList? {
        didSet {
            guard let paymentSystem = paymentSystem else { return }
            setupPaymentsUI(system: paymentSystem)
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
    
    var phoneField = PhoneNumberView(
        viewModel: .init(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            type: .phone,
            showChooseButton: true))
    
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false,
            showChooseButton: true))
    
    var bankListView = BankListView()
    
    var cardFromField = CardChooseView()
    
    var cardListView = CardsScrollView(onlyMy: false, deleteDeposit: true, loadProducts: false)
    
    var bottomView = BottomInputView()
    
    var countryListView = CountryListView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    //MARK: - Viewlifecicle
    init() {
        super.init(nibName: nil, bundle: nil)
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onTouchBackButton))
        navigationItem.leftBarButtonItem = button
    }
    
    init(paymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = paymentTemplate
        switch paymentTemplate.type {
        case .direct:
            if let model = paymentTemplate.parameterList.first as? TransferAnywayData {
                country = getCountry(code: "AM")
                typeOfPay = .mig
                configure(with: country, byPhone: true)
                
                if let bank = findBankByPuref(purefString: model.puref ?? "") {
                    selectedBank = bank
                    setupBankField(bank: bank)
                }
                
                let phone = model.additional.first(where: { $0.fieldname == "RECP" })?.fieldvalue
                phoneField.text = "+\(phone ?? "")"
            }
            
        case .contactAdressless:
            if let model = paymentTemplate.parameterList.first as? TransferAnywayData {
                typeOfPay = .contact
                if let countryCode = model.additional.first(where: { $0.fieldname == "trnPickupPoint" })?.fieldvalue {
                    country = getCountry(code: countryCode)
                    
                    configure(with: country, byPhone: false)
                    
                    
                }
                
                self.foraSwitchView.bankByPhoneSwitch.isOn = false
                self.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
                if let surName = model.additional.first(where: { $0.fieldname == "bName" })?.fieldvalue {
                    self.surnameField.text = surName
                }
                if let firstName = model.additional.first(where: { $0.fieldname == "bLastName" })?.fieldvalue {
                    self.nameField.text = firstName
                }
                if let middleName = model.additional.first(where: { $0.fieldname == "bSurName" })?.fieldvalue {
                    self.secondNameField.text = middleName
                }
                if let phone = model.additional.first(where: { $0.fieldname == "bPhone" })?.fieldvalue {
                    self.phoneField.text = "+\(phone)"
                }
            }
            
        default :
            break
        }
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back_button"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(onTouchBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    @objc func onTouchBackButton() {
        
        if operatorsViewModel != nil {
            if #available(iOS 15, *) {
            operatorsViewModel?.closeAction()
            navigationController?.popViewController(animated: true)
            } else {
                operatorsViewModel?.closeAction()
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        IQKeyboardManager.shared.enableAutoToolbar = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .black
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        if let template = paymentTemplate {
            runBlockAfterDelay(0.2) {
                self.setupAmount(amount: template.amount)
                
                if let model = self.paymentTemplate?.parameterList.first as? TransferAnywayData,
                   let currencyAmount = model.additional.first(where: { $0.fieldname == "CURR" }) {
                    
                    self.currency = currencyAmount.fieldvalue
                    
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.white
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    //MARK: - Actions
    @objc func titleDidTaped() {
        UIView.animate(withDuration: 0.2) {
            if self.countryListView.isHidden == true {
                self.countryListView.isHidden = false
                self.countryListView.alpha = 1
            } else {
                self.countryListView.isHidden = true
                self.countryListView.alpha = 0
            }
        }
    }
    
    func setupContactCountryCode(codeList: String) -> String {
        var codeDict: [[String:String]] = []
        var codeString = ""
        let list = codeList.components(separatedBy: ";")
        list.forEach { element in
            if element == "=" { } else {
                let arr = element.components(separatedBy: "=")
                let dict = [arr[0]: arr[1]]
                
                codeDict.append(dict)
                
                if arr[1] == country?.name?.capitalizingFirstLetter() {
                    codeString = arr[0]
                }
            }
        }
        return codeString
    }
    
    func clearAllFields() {
        self.puref = ""
        self.surnameField.text = ""
        self.nameField.text = ""
        self.secondNameField.text = ""
        self.phoneField.text = ""
        self.bankField.text = ""
        self.selectedBank = nil
        self.bankField.imageView.image = #imageLiteral(resourceName: "BankIcon")
    }
    
    func setupActions() {
        
        
        readAndSetupCard(type: typeOfPay)
        setupBankList()
        
        countryListView.didCountryTapped = { [weak self] country in
            self?.country = country
            self?.clearAllFields()
            UIView.animate(withDuration: 0.2) {
                self?.countryListView.isHidden = true
                self?.countryListView.alpha = 0
            }
        }
        
        countryListView.openAllCountryTapped = { [weak self] () in
            UIView.animate(withDuration: 0.2) {
                self?.countryListView.isHidden = true
                self?.countryListView.alpha = 0
            }
            let vc = ChooseCountryTableViewController()
            vc.modalPresent = true
            vc.didChooseCountryTapped = { [weak self]  (country) in
                self?.country = country
            }
            let navVc = UINavigationController(rootViewController: vc)
            self?.present(navVc, animated: true, completion: nil)
        }
        
        phoneField.didChooseButtonTapped = {() in
            let contactPickerScene = EPContactsPicker(
                delegate: self,
                multiSelection: false,
                subtitleCellType: SubtitleCellValue.phoneNumber)
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            self.present(navigationController, animated: true, completion: nil)
        }
        
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
            if self.bankListView.isHidden == false {
                self.hideView(self.bankListView, needHide: true)
            }
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
        }
        
        foraSwitchView.switchIsChanged = { [weak self] (switchView) in
            self?.clearAllFields()
            self?.typeOfPay = switchView.isOn ? .mig : .contact
            self?.configure(with: self?.country, byPhone: switchView.isOn)
        }
        
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
            if self.bankListView.isHidden == false {
                self.hideView(self.bankListView, needHide: true)
            }
        }
        
        bankField.didChooseButtonTapped = { () in
            self.openOrHideView(self.bankListView)
            self.bankListView.collectionView.reloadData()
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let products: [UserAllCardsModel] = self.cardListView.cardList
                
                products.forEach({ card in
                    if card.id == cardId {
                        self.cardFromField.model = card
                        self.selectedCardNumber = card.number ?? ""
                        if self.bankListView.isHidden == false {
                            self.hideView(self.bankListView, needHide: true)
                        }
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                        if let cardCurrency = card.currency {
                            self.bottomView.currencySwitchButton.setAttributedTitle(self.setupButtonTitle(title: cardCurrency.getSymbol() ?? "₽"), for: .normal)
                            self.bottomView.currencyButtonWidth.constant = 40
                            self.bottomView.currencySymbol = cardCurrency.getSymbol() ?? "₽"
                            self.currency = cardCurrency
                        }
                    }
                })
            }
        }
        
        cardListView.lastItemTap = {
//        TODO: Открывать все карты доработать
        }
        
        bottomView.buttonIsTapped = {
            var cur = self.country?.sendCurr?.components(separatedBy: ";").compactMap { $0 } ?? []
            if cur.count  > 1  {
                cur.removeLast()
            }
            
            if let cardCurrency = self.cardFromField.model?.currency {
                if cardCurrency == "RUB" {
                    
                    self.currency = cardCurrency
                    
                } else {
                    let currArr = self.model.currencyList.value.map { $0.getCurrencyList() }
                    currArr.forEach({ currency in
                        if currency.code == cardCurrency {
                            
                            cur = [cardCurrency, "RUR"]
                            self.currency = cardCurrency
                        }
                    })
                }
            }
            //
            let controller = ChooseCurrencyPaymentController()
            let currencyKeyArray = ["RUR","USD","EUR"]
            var currencyArrayFirstElements = [String]()
            var currencyArrayLastElements = [String]()
            currencyKeyArray.forEach { key in
                if cur.contains(key) {
                currencyArrayFirstElements.append(key)
                }
            }
            
            cur.forEach { key in
                if !currencyKeyArray.contains(key) {
                    currencyArrayLastElements.append(key)
                }
            }
            
            cur = currencyArrayFirstElements + currencyArrayLastElements.sorted(by: <)
            
            controller.elements = cur
            controller.itemIsSelect = { currency in
                self.currency = currency
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            self.present(navController, animated: true)
            
        }
        
        bottomView.didDoneButtonTapped = { [self] (amount) in
            guard let card = self.cardFromField.model else { return }
            self.showActivity()
            let phone = try? self.phoneNumberKit.parse(phoneField.textField.text ?? "").string
            let surname = self.surnameField.textField.text ?? ""
            let name = self.nameField.textField.text ?? ""
            let secondName = self.secondNameField.textField.text ?? ""
            
            switch self.typeOfPay {
            case .mig:
                self.migPayment(with: card, phone: phone, amount: Double(amount) ?? 0) { model, error in
                    self.dismissActivity()
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    } else {
                        guard let model = model else { return }
                        self.goToConfurmVC(with: model)
                    }
                }
            default:
                self.contaktPayment(with: card, surname: surname, name: name, secondName: secondName, phone: phone, amount: Double(amount) ?? 0) { model, error in
                    self.dismissActivity()
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    } else {
                        guard let model = model else { return }
                        self.goToConfurmVC(with: model)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Helpers
    func goToConfurmVC(with model: ConfirmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.getUImage = { self.model.images.value[$0]?.uiImage }
            vc.operatorsViewModel = self.operatorsViewModel
            vc.title = "Подтвердите реквизиты"
            vc.confurmVCModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getCountry(code: String) -> CountriesList {
        var countryValue: CountriesList?
        let list = model.countriesList.value.map { $0.getCountriesList() }
        list.forEach({ country in
            if country.code == code || country.contactCode == code {
                countryValue = country
            }
        })
        return countryValue!
    }
    
    func findBankByPuref(purefString: String) -> BanksList? {
        var bankValue: BanksList?
        let paymentSystems = model.paymentSystemList.value.map { $0.getPaymentSystem() }
        let bankList = model.bankList.value.map { $0.getBanksList() }
        
        paymentSystems.forEach({ paymentSystem in
            if paymentSystem.code == "DIRECT" {
                let purefList = paymentSystem.purefList
                purefList?.forEach({ puref in
                    puref.forEach({ (key, value) in
                        value.forEach { purefList in
                            if purefList.puref == purefString {
                                bankList.forEach({ bank in
                                    if bank.memberID == key {
                                        bankValue = bank
                                    }
                                })
                            }
                        }
                    })
                })
            }
        })
        return bankValue
    }
    
    func setupAmount(amount: Double?) {
        guard let moneyFormatter = bottomView.moneyFormatter else { return }
        let newText = moneyFormatter.format("\(amount ?? 0)") ?? ""
        bottomView.amountTextField.text = newText
        
        if country?.code == "АМ" {
            bottomView.doneButtonIsEnabled(newText.isEmpty && selectedBank != nil)
        } else {
            bottomView.doneButtonIsEnabled(newText.isEmpty)
        }
    }
    
    func setupBankField(bank: BanksList) {
        self.bankField.text = bank.memberNameRus ?? ""
        self.bankField.imageView.image = bank.svgImage?.convertSVGStringToImage()
        
        guard let paymentSystem = self.paymentSystem else { return }
        paymentSystem.purefList?.forEach({ dictArr in
            dictArr.keys.forEach { key in
                if key == bank.memberID {
                    let dict = dictArr[key]
                    dict?.forEach { purefList in
                        if purefList.type == "phone" {
                            self.puref = purefList.puref ?? ""
                        }
                    }
                }
            }
        })
    }
    
    private func readAndSetupCard(type: PaymentType) {
        DispatchQueue.main.async {
            var products: [UserAllCardsModel] = []
            let types: [ProductType] = [.card, .account]
            types.forEach { type in
                products.append(contentsOf: self.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
            }
            
            var filterProduct: [UserAllCardsModel] = []
            products.forEach({ card in
                    
                    if type == .contact
                        ? (card.currency == "RUB" || card.currency == "USD" || card.currency == "EUR")
                        : (card.currency == "RUB") {
                        
                        filterProduct.append(card)
                    }
            })
            
            self.cardListView.cardList = filterProduct.filter({$0.ownerID == Model.shared.clientInfo.value?.id})
            if filterProduct.count > 0 {
                if let cardId = self.paymentTemplate?.parameterList.first?.payer?.cardId {
                    
                    let card = filterProduct.first(where: { $0.id == cardId })
                    self.cardFromField.model = card
                    guard let cardNumber = card?.number else { return }
                    self.selectedCardNumber = cardNumber
                    self.cardIsSelect = true
                    
                } else if let accountId = self.paymentTemplate?.parameterList.first?.payer?.accountId {
                    
                    let card = filterProduct.first(where: { $0.id == accountId })
                    self.cardFromField.model = card
                    guard let cardNumber = card?.number else { return }
                    self.selectedCardNumber = cardNumber
                    self.cardIsSelect = true
                    
                } else {
                    
                    self.cardFromField.model = filterProduct.filter({$0.ownerID == Model.shared.clientInfo.value?.id}).first
                    guard let cardNumber  = filterProduct.filter({$0.ownerID == Model.shared.clientInfo.value?.id}).first?.number else { return }
                    self.selectedCardNumber = cardNumber
                    self.cardIsSelect = true
                }
            }
        }
    }
    
    func setupBankList() {
        
        var filteredbanksList : [BanksList] = []

        model.dictionaryBankListLegacy?.forEach { bank in
            guard let codeList = bank.paymentSystemCodeList else { return }
            guard let countrylist = self.country?.paymentSystemCodeList else { return }
            countrylist.forEach { code in
                if codeList.contains(code) {
                    filteredbanksList.append(bank)
                }
            }
        }
        self.banks = filteredbanksList
    }
}

//MARK: EPContactsPicker delegates
extension ContactInputViewController: EPPickerDelegate {
    
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError) {
        
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        
        for contact in contacts {
            
        }
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact) {
        let phoneFromContact = contact.phoneNumbers.first?.phoneNumber
        phoneField.text = phoneFromContact ?? ""
    }
    
    func epUserPhone(_ phone: String) {
 
        if phone.first == "+" {
            phoneField.text = phone
        } else {
            phoneField.text = "+\(phone)"
        }
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError) {
        
    }
    
}

extension PhoneNumber {
    static let Kit = PhoneNumberKit()
    
    var string: String {
        return PhoneNumber.Kit.format(self, toType: PhoneNumberFormat.e164)
    }
}
