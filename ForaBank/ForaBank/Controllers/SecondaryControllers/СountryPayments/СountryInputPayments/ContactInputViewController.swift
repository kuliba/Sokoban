//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ContactInputViewController: UIViewController {
    
    var typeOfPay: PaymentType = .contact {
        didSet {
            print("DEBUG: typeOfPay: ", typeOfPay)
        }
    }
    var cardIsSelect = false
    var selectedCardNumber = ""
    var puref = ""
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
            print("Set country", country ?? "nil")
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
            print("DEBUG: payment system: ", paymentSystem.name ?? "nil")
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
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
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
    
    var cardListView = CardsScrollView(onlyMy: false)
    
    var bottomView = BottomInputView()
    
    var countryListView = CountryListView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        setupActions()
        
    }

    //MARK: - Actions
    @objc func titleDidTaped() {
        print("countryField didChooseButtonTapped")
        
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
    
    func setupActions() {
        
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }
        
        setupBankList()
        
        countryListView.didCountryTapped = { [weak self] country in
            self?.country = country
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
            print("phoneField didChooseButtonTapped")
//            self.dismiss(animated: true, completion: nil)
            
            let contactPickerScene = EPContactsPicker(
                delegate: self,
                multiSelection: false,
                subtitleCellType: SubtitleCellValue.phoneNumber)
//            contactPickerScene.addCloseButton()
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
            self?.typeOfPay = switchView.isOn ? .mig : .contact
            self?.configure(with: self?.country, byPhone: switchView.isOn)
        }
        
        cardFromField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
            if self.bankListView.isHidden == false {
                self.hideView(self.bankListView, needHide: true)
            }
        }
        
        bankField.didChooseButtonTapped = { () in
            print("bankField didChooseButtonTapped")
            self.openOrHideView(self.bankListView)
            self.bankListView.collectionView.reloadData()
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
        }
        
        cardListView.didCardTapped = { card in
            self.cardFromField.model = card
            self.selectedCardNumber = card.number ?? ""
            if self.bankListView.isHidden == false {
                self.hideView(self.bankListView, needHide: true)
            }
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }            
        }
        
        cardListView.lastItemTap = {
            print("Открывать все карты доработать")
            
            
        }
        
        bottomView.didDoneButtonTapped = { (amount) in
            self.showActivity()
            let phone = self.phoneField.textField.unmaskedText ?? ""
            let surname = self.surnameField.textField.text ?? ""
            let name = self.nameField.textField.text ?? ""
            let secondName = self.secondNameField.textField.text ?? ""
            
            switch self.typeOfPay {
            case .mig:
                self.migPayment(with: self.selectedCardNumber, phone: phone, amount: amount) { model, error in
                    self.dismissActivity()
                    if error != nil {
                        print("DEBUG: Error: endContactPayment ", error ?? "")
                        self.showAlert(with: "Ошибка", and: error!)
                    } else {
                        guard let model = model else { return }
                        self.goToConfurmVC(with: model)
                    }
                }
            default:
                self.contaktPayment(with: self.selectedCardNumber, surname: surname, name: name, secondName: secondName, amount: amount) { model, error in
                    self.dismissActivity()
                    if error != nil {
                        print("DEBUG: Error: endContactPayment ", error ?? "")
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
            vc.title = "Подтвердите реквизиты"
            vc.confurmVCModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setupBankField(bank: BanksList) {
        self.bankField.text = bank.memberNameRus ?? "" //"АйДиБанк"
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
    
    func setupCardList(completion: @escaping ( _ error: String?) ->() ) {
        self.readAndSetupCard()
//        AddAllUserCardtList.add() {
//            self.readAndSetupCard()
//        }
    }
    
    private func readAndSetupCard() {
        DispatchQueue.main.async {
            var filterProduct: [UserAllCardsModel] = []
            let cards = ReturnAllCardList.cards()
            cards.forEach { product in
                if (product.productType == "CARD"
                        || product.productType == "ACCOUNT") && product.currency == "RUB" {
                    filterProduct.append(product)
                }
            }
            self.cardListView.cardList = filterProduct
            if filterProduct.count > 0 {
                self.cardFromField.model = filterProduct.first
                guard let cardNumber  = filterProduct.first?.number else { return }
                self.selectedCardNumber = cardNumber
                self.cardIsSelect = true
            }
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
                    guard let countrylist = self?.country?.paymentSystemCodeList else { return }
                    countrylist.forEach { code in
                        if codeList.contains(code) {
                            filteredbanksList.append(bank)
                        }
                    }
                }
                self?.banks = filteredbanksList
            }
        }
    }
    

}

//MARK: EPContactsPicker delegates
extension ContactInputViewController: EPPickerDelegate {
    
        func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError) {
            print("Failed with error \(error.description)")
        }
        
        func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact) {
            let phoneFromContact = contact.phoneNumbers.first?.phoneNumber
            let numbers = phoneFromContact?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: numbers)
            phoneField.text = maskPhone ?? ""
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
