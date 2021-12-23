//
//  MobilePayViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit

class MobilePayViewController: UIViewController, UITextFieldDelegate {
    
    var selectedCardNumber = 0
    
    var recipiendId = String()
    var phoneNumber: String?
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: UIImage(named: "smartphonegray")!,
            showChooseButton: true)
    )
    
    var cardField = CardChooseView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    var cardListView = CardListView()
    
    var bottomView = BottomInputView()
    
    var selectNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        phoneField.textField.delegate = self
        phoneField.rightButton.setImage(UIImage(imageLiteralResourceName: "user-plus"), for: .normal)
        if selectNumber != nil {
            phoneField.textField.text = selectNumber ?? ""
            phoneField.textField.maskString = selectNumber ?? ""
        }
        setupUI()
        phoneField.didChooseButtonTapped = {() in
            let contactPickerScene = EPContactsPicker(
                delegate: self,
                multiSelection: false,
                subtitleCellType: SubtitleCellValue.phoneNumber)
            //            contactPickerScene.addCloseButton()
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            self.present(navigationController, animated: true, completion: nil)
        }
        setupActions()
        
        bottomView.didDoneButtonTapped = { [self](amount) in
            /// Вызвать правильный метод оплаты
            self.startContactPayment(with: selectNumber ?? "", amount: amount) { [weak self] error in
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
            }
        }
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                self?.cardListView.cardList = data
                
                if data.count > 0 {
                    self?.cardField.cardModel = data.first
                    guard let cardNumber  = data.first?.cardID else { return }
                    self?.selectedCardNumber = cardNumber
                }
            }
        }
        
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
        
        cardListView.didCardTapped = { card in
            self.cardField.cardModel = card
            self.selectedCardNumber = card.cardID ?? 0
            self.hideView(self.cardListView, needHide: true)
        }
        
        cardListView.lastItemTap = {
            let vc = AllCardListViewController()
            vc.withTemplate = false
            vc.didCardTapped = { card in
                self.cardField.cardModel = card
                self.selectedCardNumber = card.cardID ?? 0
                self.hideView(self.cardListView, needHide: true)
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
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
        view.addSubview(bottomView)
        phoneField.textField.maskString = "+7 (000) 000-00-00"
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        bottomView.currencySymbol = "₽"
        
        title = "Мобильная связь"
        stackView = UIStackView(arrangedSubviews: [phoneField, cardField, cardListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
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
    
    ///  Запрос на перевод по мобильной связи
    func startContactPayment(with phone: String, amount: String, completion: @escaping (_ error: String?)->()) {
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
                let cardId = self?.cardField.cardModel?.id ?? 0
                
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
                        "fieldvalue": phone.digits]]
                ] as [String: AnyObject]
                
                NetworkManager<CreateMobileTransferDecodableModel>.addRequest(.createMobileTransfer, [:], body, completion: { [weak self] data, error in
                    
                    self?.dismissActivity()
                    if data?.errorMessage != nil {
                        completion(error)
                    }
                    
                    if data?.statusCode == 102 {
                        self?.showAlert(with: "Ошибка", and: "Минимальная сумма платежа 10 рублей")
                        completion("")
                        return
                    }
                    
                    
                    
                    if data?.statusCode == 0 {
                        let model = ConfirmViewControllerModel(type: .mobilePayment)
                        model.operatorImage = svgImage ?? ""
                        model.cardFrom = self?.cardField.cardModel
                        
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
                            vc.confurmVCModel = model
                            vc.addCloseButton()
                            vc.title = "Подтвердите реквизиты"
                            
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
    
}


extension MobilePayViewController: EPPickerDelegate {
    
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
            let mask = StringMask(mask: "+7 (000) 000-00-00")
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
        for contact in contacts {
            print("\(contact.displayName())")
        }
    }
    
}
