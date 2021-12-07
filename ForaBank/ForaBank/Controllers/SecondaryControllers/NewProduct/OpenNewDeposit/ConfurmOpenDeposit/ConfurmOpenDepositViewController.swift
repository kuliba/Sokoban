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
    var showSmsCode = false
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
            termField.text = "\(choosenRate.termName ?? "")"
            rateField.text = "\(choosenRate.rate ?? 0.0)%"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateSumm(with: startAmount)
        bottomView.amountTextField.text = moneyFormatter?.format("\(startAmount)") ?? ""
    }
    
    //MARK: - Helper
    func setupUI() {
        
        title = "Подтвердите параметры вклада"

        bottomView.currencySymbol = "₽"
        bottomView.buttomLabel.isHidden = true
        
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
        
        self.moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## ₽")
        self.bottomView.moneyInputController.formatter = self.moneyFormatter
        calculateSumm(with: startAmount)
        
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
                self.makeDepositPayment()
            } else {
                self.openDeposit(amount: amount)
            }
        }
        
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
        
        guard let initialAmount = Double(amount) else { return }
        guard let sourceCardId = self.cardFromField.model?.cardID else { return }
        guard let finOperID = self.product?.depositProductID else { return }
        guard let term = self.choosenRate?.term else { return }
        
        let body = [
            "finOperID": finOperID,
            "term": term,
            "currencyCode": "810",
            "sourceCardId": sourceCardId,
            "initialAmount": initialAmount
        ] as [String: AnyObject]
        
        self.showActivity()
        NetworkManager<OpenDepositDecodableModel>.addRequest(.openDeposit, [:], body) { respons, error in
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
    
    private func makeDepositPayment() {
        guard var code = smsCodeField.textField.text else { return }
        if code.isEmpty {
            code = "0"
        }
        let body = ["verificationCode": code] as [String: AnyObject]
        showActivity()
        
        NetworkManager<MakeTransferDecodableModel>.addRequest(.makeDepositPayment, [:], body) { respons, error in
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
                    
                    let vc: DepositSuccessViewController = DepositSuccessViewController.loadFromNib()
                    vc.confurmVCModel = confurmVCModel
                    
                    
                    vc.id = model.data?.paymentOperationDetailId ?? 0
                    switch confurmVCModel.type {
                    case .openDeposit, .phoneNumber:
                        vc.printFormType = "internal"
                    default:
                        break
                    }
                    
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
            }
        } else {
            presenter.height = (4 * 44) + 160
        }
        return presenter
    }
}
