//
//  PaymentByPhoneViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit

class PaymentByPhoneViewController: UIViewController {
    var sbp: Bool?
    var confirm: Bool?
    var selectedCardNumber = ""
    var selectedBank: BanksList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }
    
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
            image: #imageLiteral(resourceName: "Phone"),
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
            image: #imageLiteral(resourceName: "hash"),
            isEditable: false)
    )
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
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
            image: #imageLiteral(resourceName: "message-square"),
            type: .smsCode)
    )
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    var cardListView = CardListView()
    
    
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
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "otpCode"))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)

        // handle notification
    
        
        phoneField.rightButton.setImage(UIImage(imageLiteralResourceName: "user-plus"), for: .normal)
        if selectNumber != nil{
            phoneField.text = selectNumber ?? ""
        }
        view.addSubview(bottomView)
        setupUI()
        
        phoneField.didChooseButtonTapped = {() in
            
            self.dismiss(animated: true, completion: nil)
        }
        hideKeyboardWhenTappedAround()
//        getCardList()
        setupActions()
//        bankPayeer.imageView.image = bankImage
        
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
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                self?.cardListView.cardList = data
                
                if data.count > 0 {
                    self?.cardField.cardModel = data.first
//                    self?.cardField.configCardView(data.first!)
                    guard let cardNumber  = data.first?.number else { return }
                    self?.selectedCardNumber = cardNumber
                }
            }
        }
        setupBankList()
        
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
            self.hideView(self.bankListView, needHide: true)
        }
    }
    
    func setupActions() {
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
//            self.hideView(self.bankListView, needHide: true)
        }
        
        
        cardListView.didCardTapped = { card in
            self.cardField.cardModel = card
//            self.cardField.configCardView(card)
            self.selectedCardNumber = card.number ?? ""
            self.hideView(self.cardListView, needHide: true)
//            self.hideView(self.bankListView, needHide: true)
            
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
        
//        bankPayeer.text = selectBank ?? ""

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
//        DispatchQueue.main.async {
//            UIApplication.shared.keyWindow?.startIndicatingActivity()
//        }
        guard let number = phoneField.textField.unmaskedText else {
            return
        }
        guard let sum = bottomView.amountTextField.text else {
            return
        }
        
        let clearAmount = sum.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "").replacingOccurrences(of: ",", with: ".")
        var clearNumber = number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: "+", with: "")
//       let fromatNumber =
        var accountNumber: String?
        var cardNumber: String?
        
        if selectedCardNumber .count > 16{
            accountNumber = selectedCardNumber
//            cardNumber = ""
        } else {
            cardNumber = selectedCardNumber
//            accountNumber = ""
        }
        
        bottomView.doneButtonIsEnabled(true)
        
        let body = [ "check"            : false,
                     "amount"           : clearAmount,
                     "currencyAmount"   : "RUB",
                     "payer" : [
                        "cardId"        : nil,
                        "cardNumber"    : cardNumber,
                        "accountId"     : nil,
                        "accountNumber" : accountNumber
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
//                UIApplication.shared.keyWindow?.stopIndicatingActivity()
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    print("DEBUG: ", #function, error)
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let data = dataresp?.data else { return }
                    guard let statusCode = dataresp?.statusCode else { return }
                    if statusCode == 0 {
                        DispatchQueue.main.async {
//                            let vc = PhoneConfirmViewController()
//                            vc.sbp = self?.sbp
//                            vc.bankPayeer.text = self?.selectBank ?? ""
//                            vc.phoneField.text = self?.phoneField.text ?? ""
//                            vc.cardField.text = self?.cardField.text ?? ""
//                            vc.cardField.imageView.image = self?.cardField.imageView.image
//                            vc.summTransctionField.text = self?.bottomView.amountTextField.text ?? ""
//                            vc.taxTransctionField.isHidden = ((data.fee) != nil)
//                            vc.bankPayeer.chooseButton.isHidden = true
//                            vc.bankPayeer.imageView.image = self?.bankPayeer.imageView.image
//                            vc.cardField.chooseButton.isHidden = true
//                            vc.payeerField.text = data.payeeName ?? "Получатель не оперделен>"
//                            vc.otpCode = self?.otpCode
                            
                            var model = ConfirmViewControllerModel(type: .phoneNumber)
                            model.bank = self?.selectedBank
                            model.cardFrom = self?.cardField.cardModel
                            model.phone = self?.phoneField.text.digits ?? ""
                            model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                            model.summInCurrency = data.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                            model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
//                            model.comment = comment
                            model.fullName = data.payeeName ?? "Получатель не оперделен"
                            model.statusIsSuccses = true
                            
                            let vc = ContactConfurmViewController()
                            vc.confurmVCModel = model
                            vc.title = "Подтвердите реквизиты"
                            vc.addCloseButton()
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                            self?.present(navController, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG: ", #function, dataresp?.errorMessage ?? "nil")
                        self?.showAlert(with: "Ошибка", and: dataresp?.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
    func startContactPayment(with card: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
    
        let body = ["accountID": nil,
                    "cardID": nil,
                    "cardNumber": card,
                    "provider": nil,
                    "puref": "iFora||TransferC2CSTEP"] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], body, completion: { [weak self] model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(nil)
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    
                    if error != nil {
                        self?.dismissActivity()
                        self?.showAlert(with: "Ошибка", and: error!)
                        print("DEBUG: Error: ", error ?? "")
                        completion(error!)
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        self?.dismissActivity()
                        DispatchQueue.main.async {
                            self?.endSBPPayment(amount: self?.bottomView.amountTextField.text ?? "0") { error in
                                self?.showAlert(with: "Ошибка", and: error!)
                                print(error ?? "")
                            }
                        }
                        print("DEBUG: Success ")
                        completion(nil)
                    } else {
                        self?.dismissActivity()
                        self?.showAlert(with: "Ошибка", and: error!)
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        DispatchQueue.main.async {
                        if model.errorMessage == "Пользователь не авторизован"{
                            AppLocker.present(with: .validate)
                        }
                        }
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                self?.dismissActivity()
                self?.showAlert(with: "Ошибка", and: error!)
                print("DEBUG: Error: ", model.errorMessage ?? "")
                DispatchQueue.main.async {
                if model.errorMessage == "Пользователь не авторизован"{
                    AppLocker.present(with: .validate)
                }
                }
                self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        })
    }
    
    func endSBPPayment(amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
//        37477404102
        var newPhone = String()
        var clearPhone = String()
        
        newPhone = selectNumber?.digits ?? ""
        
        if newPhone.prefix(1) == "7" || newPhone.prefix(1) == "8"{
            clearPhone = String(newPhone.dropFirst())
        } else{
            clearPhone = newPhone
        }
        let clearAmount = amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "").replacingOccurrences(of: ",", with: ".")
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "RecipientID",
              "fieldvalue": clearPhone
            ],
            [ "fieldid": 1,
              "fieldname": "SumSTrs",
              "fieldvalue": clearAmount ]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { [weak self] model, error in
            if error != nil {
                self?.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                self?.showAlert(with: "Ошибка", and: error!)
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                self?.dismissActivity()
                print("DEBUG: Success send Phone")
                DispatchQueue.main.async {
                    self?.endSBPPayment2()
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                self?.showAlert(with: "Ошибка", and: error!)
                DispatchQueue.main.async {
                if model.errorMessage == "Пользователь не авторизован"{
                    AppLocker.present(with: .validate)
                }
                }
                self?.dismissActivity()
                self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
    }
    
    func endSBPPayment2() {
        showActivity()
//        37477404102
        guard let memberId = self.selectedBank?.memberID else {
            return
        }
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "BankRecipientID",
              "fieldvalue": memberId]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { [weak self] dataresp, error in
            if error != nil {
                self?.dismissActivity()
                self?.showAlert(with: "Ошибка", and: error!)
                print("DEBUG: Error: ", error ?? "")
                
            }
//            print("DEBUG: amount ", amount)
            guard let data = dataresp else { return }
            if data.statusCode == 0 {
                print("DEBUG: Success send Phone")
                self?.dismissActivity()
                self?.confirm = true
//                self.setupUI()
                DispatchQueue.main.async {
                    
                    var model = ConfirmViewControllerModel(type: .phoneNumberSBP)
                    if self?.selectedBank != nil {
                        model.bank = self?.selectedBank
                    } else {
                        
                    }
                    
                    model.cardFrom = self?.cardField.cardModel
                    model.phone = self?.phoneField.text.digits ?? ""
                    
                    model.summTransction = data.data?.amount?.currencyFormatter(symbol: "RUB") ?? ""// debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
//                    model.summInCurrency = model.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                    model.taxTransction = data.data?.commission?.currencyFormatter(symbol: "RUB") ?? ""
//                            model.comment = comment
                    model.fullName = data.data?.listInputs?[5].content?[0] ?? "Получатель не найден"
                    
                    model.numberTransction = data.data?.id ?? ""
                    
                    model.statusIsSuccses = true
                    
                    let vc = ContactConfurmViewController()
                    vc.confurmVCModel = model
                    vc.addCloseButton()
                    vc.title = "Подтвердите реквизиты"
                    
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self?.present(navController, animated: true, completion: nil)
                    
                }
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
                
            } else {
                self?.dismissActivity()
                self?.showAlert(with: "Ошибка", and: data.errorMessage ?? "")
                print("DEBUG: Error: ", data.errorMessage ?? "")
                
            }
        }
        
    }
}
