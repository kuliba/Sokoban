    //
    //  ConfurmOpenDepositViewController.swift
    //  ForaBank
    //
    //  Created by Mikhail on 03.12.2021.
    //

    import UIKit
    import AnyFormatKit
    import IQKeyboardManagerSwift

    class ConfurmOpenDepositViewController: PaymentViewController { 
        
        var getUImage: (Md5hash) -> UIImage? = { _ in UIImage() }
        var startAmount: Double = 5000.0
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
        
        var product: OpenDepositDatum? {
            didSet {
                guard let product = product else { return }
                nameField.text = product.name ?? ""
            }
        }
        var choosenRateList: [TermRateSumTermRateList]?
        var choosenRateListWithCap: [TermRateSumTermRateList]?
        
        var depositModels: DepositCalculatorViewModel.DepositInterestRateModel?
        var withCapRate: Bool = false
        var choosenRate: TermRateSumTermRateList? {
            didSet {
                guard let choosenRate = choosenRate else { return }
                
                if let i = depositModels {
                    
                    guard let text = self.bottomView.amountTextField.text else { return }
                    guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
                    guard let value = Double(unformatText) else { return }
                    
                    let point = i.points
                        .compactMap {$0}
                        .last { point in
                            point.minSumm <= value
                        }
                    
                    guard let point = point else {
                        return
                    }
                    
                    let itemViewModel = point.termRateLists.first { model in
                        model.term == choosenRate.term
                    }
                    
                    guard let itemViewModel = itemViewModel else {
                        return
                    }
                    
                    let dateDepositButtontext = "\(itemViewModel.termName) (\(itemViewModel.term) \(WordDeclensionUtil.getWordInDeclension(type: WordDeclensionEnum().day, n: itemViewModel.term )))"
                    
                    termField.text = dateDepositButtontext
                    rateField.text = "\(itemViewModel.rate)%"
                    calculateSumm(with: value)
                    
                } else {
                    
                    let dateDepositButtontext = "\(choosenRate.termName ?? "") (\(choosenRate.term ?? 0) \(WordDeclensionUtil.getWordInDeclension(type: WordDeclensionEnum().day, n: choosenRate.term )))"
                    termField.text = dateDepositButtontext
                    rateField.text = "\(choosenRate.rate ?? 0.0)%"
                    guard let text = self.bottomView.amountTextField.text else { return }
                    guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
                    guard let value = Double(unformatText) else { return }
                    calculateSumm(with: value)
                }
            }
        }
        var moneyFormatter: SumTextInputFormatter?
        
        var nameField = ForaInput(
            viewModel: ForaInputModel(
                title: "Наименование вклада",
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
                image: #imageLiteral(resourceName: "PercentDeposit"),
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
                
                if let depositModels = self.depositModels {
                    
                    guard let text = self.bottomView.amountTextField.text else { return }
                    guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
                    guard let value = Double(unformatText) else { return }
                    
                    let point = depositModels.points
                        .compactMap {$0}
                        .last { point in
                            point.minSumm <= value
                        }
                    
                    guard let point = point else {
                        return
                    }
                    
                    let itemViewModel = point.termRateLists.first { model in
                        model.termName == self.choosenRate?.termName
                    }
                    
                    guard let itemViewModel = itemViewModel else {
                        return
                    }
                    
                    let dateDepositButtontext = "\(itemViewModel.termName ) (\(itemViewModel.term) \(WordDeclensionUtil.getWordInDeclension(type: WordDeclensionEnum().day, n: itemViewModel.term )))"
                    
                    self.termField.text = dateDepositButtontext
                    self.rateField.text = "\(itemViewModel.rate)%"
                    self.calculateSumm(with: value)
                    
                    
                } else {
                    guard let text = self.bottomView.amountTextField.text else { return }
                    guard let unformatText = self.bottomView.moneyFormatter?.unformat(text) else { return }
                    guard let value = Double(unformatText) else { return }
                    self.calculateSumm(with: value)
                    
                    //TODO: - Validate summ
                    let intValue = Int(unformatText) ?? 0
                    let minSumm = self.product?.generalСondition?.minSum ?? 5000
                    let maxSumm = Int(self.cardFromField.model?.balance ?? 0)
                    if intValue < minSumm ||
                        intValue > maxSumm {
                        
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: bottomView.amountTextField, queue: .main) { _ in
                guard let text = self.bottomView.amountTextField.text else { return }
                guard let unformatText = self.bottomView.moneyFormatter?.unformat(text) else { return }
                guard let value = Int(unformatText) else { return }
                if value < self.product?.generalСondition?.minSum ?? 5000 {
                    let newText = self.bottomView.moneyFormatter?.format("\(self.product?.generalСondition?.minSum ?? 5000)")
                    self.bottomView.amountTextField.text = newText
                    self.calculateSumm(with: Double(self.product?.generalСondition?.minSum ?? 5000))
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.setOtpCode(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## ₽")
            rateField.imageView.setDimensions(height: 24, width: 24)
            
            let newText = moneyFormatter?.format("\(startAmount)") ?? ""
            bottomView.amountTextField.text = newText
            
            let dateDepositButtontext = "\(choosenRate?.termName ?? "") (\(choosenRate?.term ?? 0) \(WordDeclensionUtil.getWordInDeclension(type: WordDeclensionEnum().day, n: choosenRate?.term ?? 0)))"
            termField.text = dateDepositButtontext
            rateField.text = "\(choosenRate?.rate ?? 0)%"
            
            calculateSumm(with: startAmount)
            
            bottomView.doneButtonIsEnabled(newText.isEmpty)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                
                IQKeyboardManager.shared.enable = true
                IQKeyboardManager.shared.enableAutoToolbar = true
                IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
            }
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            IQKeyboardManager.shared.enable = false
            IQKeyboardManager.shared.enableAutoToolbar = false
            IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    
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
            
            cardFromField.getUImage = getUImage
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
                self.openOrHideView(self.cardListView)
            }
            
            cardListView.didCardTapped = { cardId in
                DispatchQueue.main.async {
                    let cardList = ReturnAllCardList.cards()
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
                if !self.withCapRate {
                    controller.titleLabel.text = "Представленные параметры являются расчетными и носят справочный характер"
                }
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .custom
                navController.transitioningDelegate = self
                self.present(navController, animated: true)
            }
            
        }
        
        @objc func setOtpCode(_ notification: NSNotification) {
            
            let otpCode: String
            
            
            if let dict = notification.userInfo as NSDictionary? {
                
                if let code = dict["otp"] as? String {
                    
                    otpCode = code
                } else if let code = dict["aps.alert.body"] as? String {
                    otpCode = code
                } else {
                    return
                }
            } else {
                return
            }
            smsCodeField.text = otpCode.filter { "0"..."9" ~= $0 }
        }
        
        private func readAndSetupCard() {
            DispatchQueue.main.async {
                var filterProduct: [UserAllCardsModel] = []
                let cards = ReturnAllCardList.cards()
                cards.forEach { product in
                    if (product.productType == "CARD" ||
                        product.productType == "ACCOUNT") &&
                        product.currency == "RUB" &&
                        !(product.cardType?.isCorporate ?? false) {
                        
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
        private func calculateSumm(with value: Double) {
            if withCapRate {
                
                chooseRate(from: value)
                var interestRate = Double(choosenRate?.rate ?? 0)
                if let capList = choosenRateListWithCap {

                    for i in capList {
                        if i.term == choosenRate?.term, i.termName == choosenRate?.termName {
                            interestRate = Double(i.rate ?? 0)
                        }
                    }
                }

                let termDay = Double(choosenRate?.term ?? 0)
                
                
                let income = ( (value * interestRate * termDay) / 365 ) / 100
                incomeField.text = moneyFormatter?.format("\(income)") ?? ""

            } else {
                chooseRate(from: value)
                let interestRate = Double(choosenRate?.rate ?? 0)
                let termDay = Double(choosenRate?.term ?? 0)
                
                let income = ( (value * interestRate * termDay) / 365 ) / 100
                incomeField.text = moneyFormatter?.format("\(income)") ?? ""
            }
        }
        
        private func chooseRate(from value: Double) {
            guard let mainRateList = self.product?.termRateList else { return }
            mainRateList.forEach { termRateList in
                if termRateList.сurrencyCode == "810" {
                    let termRateSumm = termRateList.termRateSum
                    termRateSumm?.forEach({ rateSum in
                        if value >= Double(rateSum.sum ?? 0) {
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
                    self.showAlert(with: "Ошибка", and: error ?? "")
                }
                guard let model = respons else { return }
                if model.statusCode == 0 {
                    self.showSmsCode = true
                    self.hideView(self.smsCodeField, needHide: false)
                } else {
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                }
            }
        }
        
        private func makeDepositPayment(amount: String) {
            guard let initialAmount = Double(amount) else { return }
            guard let card = self.cardFromField.model else { return }
            guard let finOperID = self.product?.depositProductID else { return }
            guard let term = self.choosenRate?.termABS else { return }
            guard var code = smsCodeField.textField.text else { return }
            
            if code.isEmpty {
                code = "0"
            }
            
            var body = [
                "finOperID": finOperID,
                "term": term,
                "termKind": self.choosenRate?.termKind ?? nil,
                "termType": self.choosenRate?.termType,
                "currencyCode": "810",
                "initialAmount": initialAmount,
                "verificationCode": code
            ] as [String: AnyObject]
            
            if card.productType == "CARD" {
                body["sourceCardId"] = card.cardID as AnyObject
            } else if card.productType == "ACCOUNT" {
                body["sourceAccountId"] = card.id as AnyObject
            }
            showActivity()
            
            Model.shared.productsOpening.value.insert(.deposit)
            
            NetworkManager<MakeDepositDecodableModel>.addRequest(.makeDepositPayment, [:], body) { respons, error in
                
                Model.shared.productsOpening.value.remove(.deposit)
                
                DispatchQueue.main.async {
                    self.dismissActivity()
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error ?? "")
                    }
                    guard let model = respons else { return }
                    
                    if model.statusCode == 0 {
                        
                        var status = ConfirmViewControllerModel.StatusOperation.succses
                        
                        switch model.data?.documentStatus{
                        case .some("COMPLETE"):
                            status = .succses
                            
                        case .some("IN_PROGRESS"):
                            status = .inProgress
                            
                        case .some("REJECTED"):
                            status = .error
                            
                        case .some("SUSPEND"):
                            status = .antifraudCanceled
                            
                        case .some(_):
                            status = .error
                            
                        case .none:
                            status = .error
                        }
                        
                        let confurmVCModel = ConfirmViewControllerModel(
                            type: .openDeposit,
                            status: status
                        )
                        confurmVCModel.cardFromRealm = self.cardFromField.model
                        confurmVCModel.fullName = self.product?.name
                        confurmVCModel.summTransction = self.bottomView.amountTextField.text ?? ""
                        confurmVCModel.taxTransction = self.incomeField.text
                        confurmVCModel.phone = self.termField.text
                        confurmVCModel.summInCurrency = self.rateField.text
                        confurmVCModel.numberTransction = model.data?.accountNumber ?? ""
                        if let closeDate = model.data?.closeDate {
                            
                            let formatter = DateFormatter.closeDepositDate
                            let date = Date(timeIntervalSince1970: TimeInterval((closeDate)/1000))
                            confurmVCModel.dateOfTransction = formatter.string(from: date)
                        }
                        let vc: DepositSuccessViewController = DepositSuccessViewController.loadFromNib()
                        vc.confurmVCModel = confurmVCModel
                        vc.id = model.data?.paymentOperationDetailId ?? 0
                        vc.printFormType = "internal"
                        vc.modalPresentationStyle = .fullScreen
                        
                        self.present(vc, animated: true, completion: nil)
                    } else {
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
