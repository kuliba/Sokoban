//
//  ConfurmOpenDepositViewController.swift
//  ForaBank
//
//  Created by Mikhail on 03.12.2021.
//

import UIKit
import AnyFormatKit
import RealmSwift

class ConfurmOpenDepositViewController: PaymentViewController {
    
    var startAmount: Float = 5000.0
    var showSmsCode = false {
        didSet {
            if showSmsCode {
                UIView.animate(withDuration: 0.3) {
                    self.bottomView.doneButton.setTitle("Открыть", for: .normal)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.bottomView.doneButton.setTitle("Продолжить", for: .normal)
                }
            }
        }
    }
    lazy var realm = try? Realm()
    var product: OpenDepositDatum? {
        didSet {
            guard let product = product else { return }
            nameField.text = product.name ?? ""
        }
    }
    var choosenRateList: [TermRateSumTermRateList]?
    var choosenRate: TermRateSumTermRateList? {
        didSet {
            guard let choosenRate = choosenRate else { return }
            let dateDepositButtontext = "\(choosenRate.termName ?? "") (\(choosenRate.term ?? 0) \(WordDeclensionUtil.getWordInDeclension(type: WordDeclensionEnum().day, n: choosenRate.term )))"
            termField.text = dateDepositButtontext
            rateField.text = "\(choosenRate.rate ?? 0.0)%"
            guard let text = self.bottomView.amountTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            guard let value = Float(unformatText) else { return }
            calculateSumm(with: value)
        }
    }
    var moneyFormatter: SumTextInputFormatter?
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Наименования вклада",
            image: UIImage(named: "depositIcon")!,
            isEditable: false))
    
    var termField = ForaInput(
        viewModel: ForaInputModel(
            title: "Срок вклада",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false,
            showChooseButton: true))
    
    var rateField = ForaInput(
        viewModel: ForaInputModel(
            title: "Процентная ставка",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var incomeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Ваш потенциальный доход",
            image: #imageLiteral(resourceName: "Frame 579"),
            isEditable: false,
            showChooseButton: true))
    
    var cardFromField = CardChooseView()
    
    var cardListView = CardsScrollView(onlyMy: false)
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: UIImage(named: "message-square")!,
            type: .smsCode))
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        readAndSetupCard()
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: bottomView.amountTextField, queue: .main) { _ in
            guard let text = self.bottomView.amountTextField.text else { return }
            guard let unformatText = self.bottomView.moneyFormatter?.unformat(text) else { return }
            guard let value = Float(unformatText) else { return }
            self.calculateSumm(with: value)
            
            //TODO: - Validate summ
            let intValue = Int(unformatText) ?? 0
            let minSumm = self.product?.generalСondition?.minSum ?? 5000
            let maxSumm = Int(self.cardFromField.model?.balance ?? 0)
            if intValue < minSumm ||
                intValue > maxSumm {
                
                print("TODO: - Validate summ")
                
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: bottomView.amountTextField, queue: .main) { _ in
            guard let text = self.bottomView.amountTextField.text else { return }
            guard let unformatText = self.bottomView.moneyFormatter?.unformat(text) else { return }
            guard let value = Int(unformatText) else { return }
            if value < self.product?.generalСondition?.minSum ?? 5000 {
                let newText = self.bottomView.moneyFormatter?.format("\(self.product?.generalСondition?.minSum ?? 5000)")
                self.bottomView.amountTextField.text = newText
                self.calculateSumm(with: Float(self.product?.generalСondition?.minSum ?? 5000))
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setOtpCode(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## ₽")
        
        let newText = moneyFormatter?.format("\(startAmount)") ?? ""
        bottomView.amountTextField.text = newText
        calculateSumm(with: startAmount)
        
        bottomView.doneButtonIsEnabled(newText.isEmpty)
    }
    
    //MARK: - Helper
    func setupUI() {
        
        title = "Подтвердите параметры вклада"
        
        incomeField.chooseButton.setImage(UIImage(named: "info"), for: .normal)
        
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(termField)
        stackView.addArrangedSubview(rateField)
        stackView.addArrangedSubview(incomeField)
        stackView.addArrangedSubview(cardFromField)
        stackView.addArrangedSubview(cardListView)
        stackView.addArrangedSubview(smsCodeField)
        
        smsCodeField.isHidden = true
        smsCodeField.alpha = 0
        
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        termField.didChooseButtonTapped = {
            let controller = SelectDepositPeriodViewController()
            controller.elements = self.choosenRateList
            controller.itemIsSelect = { elem in
                self.choosenRate = elem
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            self.present(navController, animated: true)
        }
        
        cardFromField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.cardFromField.model = card
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                    }
                })
            }         
        }
        
        bottomView.didDoneButtonTapped = { amount in
            if self.showSmsCode {
                self.makeDepositPayment(amount: amount)
            } else {
                self.openDeposit(amount: amount)
            }
        }
        
        incomeField.didChooseButtonTapped = {
            let controller = DepositInfoViewController()
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            self.present(navController, animated: true)
        }
        
    }
    
    @objc func setOtpCode(_ notification: NSNotification) {
        let otpCode = notification.userInfo?["body"] as! String
//        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
        smsCodeField.text = otpCode.filter { "0"..."9" ~= $0 }
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
            }
        }
    }
    
    //MARK: - Calculator
    private func calculateSumm(with value: Float) {
        chooseRate(from: value)
        let interestRate = Float(choosenRate?.rate ?? 0)
        let termDay = Float(choosenRate?.term ?? 0)
        
        let income = ( (value * interestRate * termDay) / 365 ) / 100
        incomeField.text = moneyFormatter?.format("\(income)") ?? ""
    }
    
    private func chooseRate(from value: Float) {
        guard let mainRateList = self.product?.termRateList else { return }
        mainRateList.forEach { termRateList in
            if termRateList.сurrencyCode == "810" {
                let termRateSumm = termRateList.termRateSum
                termRateSumm?.forEach({ rateSum in
                    if value >= Float(rateSum.sum ?? 0) {
                        choosenRateList = rateSum.termRateList
                    }
                })
            }
        }
    }
    
    
    //MARK: - Animation
    func openOrHideView(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if view.isHidden == true {
                    view.isHidden = false
                    view.alpha = 1
                } else {
                    view.isHidden = true
                    view.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    func hideView(_ view: UIView, needHide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - API
    private func openDeposit(amount: String) {
        
        self.showActivity()
        NetworkManager<OpenDepositDecodableModel>.addRequest(.openDeposit, [:], [:]) { respons, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error openDeposit:", error ?? "")
                self.showAlert(with: "Ошибка", and: error ?? "")
            }
            guard let model = respons else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success openDeposit")
                self.showSmsCode = true
                self.hideView(self.smsCodeField, needHide: false)
            } else {
                print("DEBUG: Error openDeposit:", model.errorMessage ?? "")
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
            }
        }
    }
    
    private func makeDepositPayment(amount: String) {
        guard let initialAmount = Double(amount) else { return }
        guard let card = self.cardFromField.model else { return }
        guard let finOperID = self.product?.depositProductID else { return }
        guard let term = self.choosenRate?.term else { return }
        guard var code = smsCodeField.textField.text else { return }
        if code.isEmpty {
            code = "0"
        }
        
        var body = [
            "finOperID": finOperID,
            "term": term,
            "currencyCode": "810",
            "initialAmount": initialAmount,
            "verificationCode": code
        ] as [String: AnyObject]
        
        if card.productType == "CARD" {
            body["sourceCardId"] = card.cardID as AnyObject
        } else if card.productType == "ACCOUNT" {
            body["sourceAccountId"] = card.id as AnyObject
        }
        print(body)
        showActivity()
        
        NetworkManager<MakeDepositDecodableModel>.addRequest(.makeDepositPayment, [:], body) { respons, error in
            DispatchQueue.main.async {
                self.dismissActivity()
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                    self.showAlert(with: "Ошибка", and: error ?? "")
                }
                guard let model = respons else { return }
                
                if model.statusCode == 0 {
                    print("DEBUG: Success payment")
                    
                    let confurmVCModel = ConfirmViewControllerModel(type: .openDeposit)
                    confurmVCModel.cardFromRealm = self.cardFromField.model
                    confurmVCModel.fullName = self.product?.name
                    confurmVCModel.summTransction = self.bottomView.amountTextField.text ?? ""
                    confurmVCModel.taxTransction = self.incomeField.text
                    confurmVCModel.phone = self.termField.text
                    confurmVCModel.summInCurrency = self.rateField.text
                    confurmVCModel.numberTransction = model.data?.accountNumber ?? ""
                    let formatter = Date.dateFormatterSimpleDateConvenient()
                    let date = Date(timeIntervalSince1970: TimeInterval((model.data?.closeDate ?? 0)/1000))
                    confurmVCModel.dateOfTransction = formatter.string(from: date)
                    let vc: DepositSuccessViewController = DepositSuccessViewController.loadFromNib()
                    vc.confurmVCModel = confurmVCModel
                    vc.id = model.data?.paymentOperationDetailId ?? 0
                    vc.printFormType = "internal"
                    vc.modalPresentationStyle = .fullScreen
                    
                    self.present(vc, animated: true, completion: nil)
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                }
            }
        }
    }
}

//MARK: - TransitioningDelegate
extension ConfurmOpenDepositViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        if let nav = presented as? UINavigationController {
            if let controller = nav.viewControllers.first as? SelectDepositPeriodViewController {
                presenter.height = ((controller.elements?.count ?? 1) * 56) + 80
            } else {
                presenter.height = 300
            }
        } else {
            presenter.height = 300
        }
        return presenter
    }
}
