//
//  PaymentByPhoneViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit
import SVGKit


class PaymentByPhoneViewController: UIViewController {
    var sbp: Bool?
    var selectBank: String?
    var confirm: Bool?
    var selectedCardNumber = ""
    var bankImage: UIImage?
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            showChooseButton: true))
    
    
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false
            ))
    
    var bankPayeer = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: UIImage(),
            isEditable: false,
            showChooseButton: true)
            )
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: true))
    
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: #imageLiteral(resourceName: "hash"),
            isEditable: false))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: true))
    
    var commentField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сообщение получателю",
            image: #imageLiteral(resourceName: "message"),
            isEditable: true))
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: #imageLiteral(resourceName: "message-square"),
            type: .smsCode))
    
    var stackView = UIStackView(arrangedSubviews: [])

    var cardListView = CardListView()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var bottomView = BottomInputView()
    
    var otpCode: String?
    
    var selectNumber: String?
    
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
        bankPayeer.imageView.image = bankImage
        
        bottomView.didDoneButtonTapped = {(amount) in
            switch self.sbp{
            case true:
                self.startContactPayment(with: self.selectedCardNumber) { [self] error in
                    self.dismissActivity()
                    DispatchQueue.main.async {
                        endSBPPayment(selectBank: selectBank!, amount: bottomView.amountTextField.text ?? "0") { error in
                            print(error ?? "")
                        }
                    }
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
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
                    self?.cardField.configCardView(data.first!)
                    guard let cardNumber  = data.first?.number else { return }
                    self?.selectedCardNumber = cardNumber
                }
            }
        }
        
        
    }
    
    
    
    func setupActions() {
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
//            self.hideView(self.bankListView, needHide: true)
        }
        
        
        cardListView.didCardTapped = { card in
            self.cardField.configCardView(card)
            self.selectedCardNumber = card.number ?? ""
            self.hideView(self.cardListView, needHide: true)
//            self.hideView(self.bankListView, needHide: true)
            
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
    
    
    @objc func doneButtonTapped() {
        switch sbp{
        case true:
            self.startContactPayment(with: selectedCardNumber) { [self] error in
                self.dismissActivity()
                DispatchQueue.main.async {
                    endSBPPayment(selectBank: selectBank!, amount: bottomView.amountTextField.text ?? "") { error in
                        print(error ?? "")
                    }
                }
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        default:
                prepareCard2Phone()
        }
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        
        
        bankPayeer.text = selectBank ?? ""
        bottomView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                          right: view.rightAnchor, paddingBottom: 20)
        bottomView.currency = "₽"

            
        title = "Перевод по номеру телефона"
        stackView = UIStackView(arrangedSubviews: [phoneField, bankPayeer,cardField,cardListView, commentField])
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
        
        cardListView.didCardTapped = {[weak self] (card) in
            print(card)
        }
        cardField.didChooseButtonTapped = { () in
            UIView.animate(withDuration: 0.2, animations: {
                self.cardListView.isHidden.toggle()
            })
        }
    }
    
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        NetworkHelper.request(.getProductList) { cardList , error in
            if error != nil {
                completion(nil, error)
            }
            guard let cardList = cardList as? [GetProductListDatum] else { return }
            completion(cardList, nil)
            print("DEBUG: Load card list... Count is: ", cardList.count)
        }
    }
    
    
    func createTransfer() {
        self.dismissKeyboard()
        self.showActivity()
//        DispatchQueue.main.async {
//            UIApplication.shared.keyWindow?.startIndicatingActivity()
//        }
        guard let number = phoneField.textField.text else {
            return
        }
        guard let sum = bottomView.amountTextField.text else {
            return
        }
        let clearSum = NSString(string: "\(sum.replacingOccurrences(of: ",", with: "."))").doubleValue //123
        
        bottomView.doneButtonIsEnabled(true)
        let body = [ "check" : false,
                     "amount" : clearSum,
                     "currencyAmount" : "RUB",
                     "payer" : [
                        "cardId" : nil,
                        "cardNumber" : selectNumber,
                        "accountId" : nil,
                        "accountNumber" : nil
                     ],
                     "payeeInternal" : [
                        "cardId" : nil,
                        "cardNumber" : nil,
                        "accountId" : nil,
                        "accountNumber" : nil,
                        "phoneNumber" : number,
                        "productCustomName" : nil
                     ] ] as [String : AnyObject]
        
        print("DEBUG: ", #function, body)
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            DispatchQueue.main.async {
//                UIApplication.shared.keyWindow?.stopIndicatingActivity()
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    print("DEBUG: ", #function, error)
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {

                        DispatchQueue.main.async {
                            let vc = PhoneConfirmViewController()
                            vc.sbp = self?.sbp
                            vc.bankPayeer.text = self?.selectBank ?? ""
                            vc.phoneField.text = self?.phoneField.text ?? ""
                            vc.cardField.text = self?.cardField.text ?? ""
                            vc.cardField.imageView.image = self?.cardField.imageView.image
                            vc.summTransctionField.textField.text = self?.bottomView.amountTextField.text
                            vc.taxTransctionField.isHidden = ((model.data?.fee) != nil)
                            vc.bankPayeer.chooseButton.isHidden = true
                            vc.bankPayeer.imageView.image = self?.bankPayeer.imageView.image
                            vc.cardField.chooseButton.isHidden = true
//                            vc.payeerField.text = model.data?. ?? "Получатель не определен"
                            vc.otpCode = self?.otpCode
                            vc.addCloseButton()
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                            self?.present(navController, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG: ", #function, model.errorMessage ?? "nil")
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
    func prepareCard2Phone(){
        showActivity()
        guard let number = phoneField.textField.text else {
            return
        }
        guard let sum = bottomView.amountTextField.text else {
            return
        }
        let clearSum = NSString(string: "\(sum.replacingOccurrences(of: ",", with: "."))").doubleValue //123
        
        let body = ["payerCardNumber": "\(selectedCardNumber)",
                    "payeePhone": "\(number)",
                    "amount": clearSum
                    ] as [String: AnyObject]
        NetworkManager<PrepareCard2PhoneDecodableModel>.addRequest(.prepareCard2Phone, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()

//                guard let data  = model.data else { return }
                DispatchQueue.main.async {
                    let vc = PhoneConfirmViewController()
                    vc.sbp = self.sbp
                    vc.bankPayeer.text = self.selectBank ?? ""
                    vc.phoneField.text = self.phoneField.text
                    vc.cardField.text = self.cardField.text
                    vc.cardField.imageView.image = self.cardField.imageView.image
                    vc.summTransctionField.textField.text = self.bottomView.amountTextField.text
                    vc.taxTransctionField.isHidden = ((model.data?.commission?.isEmpty) != nil)
                    vc.bankPayeer.chooseButton.isHidden = true
                    vc.bankPayeer.imageView.image = self.bankPayeer.imageView.image
                    vc.cardField.chooseButton.isHidden = true
                    vc.payeerField.text = model.data?.payeeName ?? "Получатель не определен"
                    vc.otpCode = self.otpCode
                    vc.addCloseButton()
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)                }
            } else {
                self.dismissActivity()

                print("DEBUG: Error: ", model.errorMessage ?? "")
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
        
        NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], body, completion: { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(nil)
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    if error != nil {
                        self.dismissActivity()
                        print("DEBUG: Error: ", error ?? "")
                        completion(error!)
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success ")
                        completion(nil)
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        })
    }
    
    func endSBPPayment(selectBank: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
//        37477404102
        let clearAmount = amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "")
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "RecipientID",
              "fieldvalue": "0115110217" ],
            [ "fieldid": 1,
              "fieldname": "SumSTrs",
              "fieldvalue": clearAmount ]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                    self.dismissActivity()
                    self.endSBPPayment2()
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
    }
    
    func endSBPPayment2() {
        showActivity()
//        37477404102
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "BankRecipientID",
              "fieldvalue": "1crt88888881"]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                self.dismissActivity()
                self.confirm = true
//                self.setupUI()
                DispatchQueue.main.async {
                    let vc = PhoneConfirmViewController()
                    vc.sbp = self.sbp
                    
                    vc.bankPayeer.text = self.selectBank ?? ""
                    vc.phoneField.text = self.phoneField.text
                    vc.cardField.text = self.cardField.text
                    vc.bankPayeer.imageView.image = self.bankPayeer.imageView.image
                    vc.summTransctionField.text = self.bottomView.amountTextField.text  ?? ""
                    vc.bankPayeer.chooseButton.isHidden = true
                    vc.cardField.chooseButton.isHidden = true
                    vc.payeerField.text = model.data?.listInputs?[5].content?[0] ?? "Получатель не найден"
                    if model.data?.commission == 0.0 {
                        vc.taxTransctionField.text = "Комиссия не взимается"
                    } else {
                        vc.taxTransctionField.text = model.data?.commission?.description ?? "Возможна комиссия"
                    }
                    vc.addCloseButton()
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                    
                }
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
                
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                
            }
        }
        
    }
}
