//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
import RealmSwift
import AnyFormatKit
import IQKeyboardManagerSwift

class MemeDetailVC: UIViewController {

    var titleLabel = UILabel(text: "На другую карту", font: .boldSystemFont(ofSize: 18), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    var onlyMy = false
    var onlyCard = true
    var anotherCardModel: AnotherCardViewModel?
    var paymentTemplate: PaymentTemplateData? = nil
    
    var viewModel = ConfirmViewControllerModel(type: .card2card, status: .succses) {
        didSet {
            checkModel(with: viewModel)
        }
    }
    
    var cardFromField = CardChooseView()
    var seporatorView = SeparatorView()
    var cardFromListView: CardsScrollView!
    var cardToField = CardChooseView()
    var cardToListView: CardsScrollView!
    var bottomView = BottomInputView(formater: SumTextInputFormatter(textPattern: "# ###,## ₽"))
    lazy var cardView = CastomCardView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    let model = Model.shared
    var token: NotificationToken?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(paymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = paymentTemplate
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        setupActions()
        setupCardViewActions()
        hideKeyboardWhenTappedAround()
        if let template = paymentTemplate {
            addBackButton()
            updateObjectWithTamplate(paymentTemplate: template)
            let cardId = template.parameterList.first?.payer?.cardId
            updateObjectWithNotification(cardId: cardId)
        } else {
            updateObjectWithNotification()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let template = paymentTemplate {
            runBlockAfterDelay(0.2) {
                self.setupAmount(amount: template.amount)
            }
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    deinit {
        token?.invalidate()
    }
    
    private func setupUI() {
        setupFieldFrom()
        setupFieldTo()
        setupListFrom()
        setupListTo()
                
//        paymentTemplate == nil ? self.addHeaderImage() : nil
        
        self.view.layer.cornerRadius = 16
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
        self.view.backgroundColor = .white
        
        stackView = UIStackView(
            arrangedSubviews: [cardFromField,
                               seporatorView,
                               cardFromListView,
                               cardToField,
                               cardToListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
    }
    
    private func setupConstraint() {
        view.addSubview(titleLabel)
        titleLabel.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            paddingTop: 28,
            paddingLeft: 20)
        
        view.addSubview(bottomView)
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(
            top: view.safeAreaLayoutGuide.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        stackView.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 16)
    }
    
    func updateObjectWithTamplate(paymentTemplate: PaymentTemplateData) {
        title = paymentTemplate.name
        titleLabel.text = ""
        
        
        let button = UIBarButtonItem(image: UIImage(named: "edit-2"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(updateNameTemplate))
        button.tintColor = .black
        navigationItem.rightBarButtonItem = button
        
        
        switch paymentTemplate.type {
        case .insideBank:
            
            //FIXME: GetProductTemplateDatum и PaymentTemplateData идентичны и используются одинаково нужно изучить
            
            if let cardTemp = paymentTemplate.productTemplate {
                let card = GetProductTemplateDatum(with: cardTemp)
                cardToField.tempCardModel = card
                viewModel.customCardTo = CastomCardViewModel(cardNumber: card.numberMask ?? "", cardName: card.customName, cardId: card.id)
            }
            
        default:
            break
        }
    }
    
    @objc private func updateNameTemplate() {
        self.showInputDialog(title: "Название шаблона",
                             actionTitle: "Сохранить",
                             cancelTitle: "Отмена",
                             inputText: paymentTemplate?.name,
                             inputPlaceholder: "Введите название шаблона",
                             actionHandler:  { text in
            
            guard let text = text else { return }
            guard let templateId = self.paymentTemplate?.paymentTemplateId else { return }
            
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
    
    func setupAmount(amount: Double?) {
        guard let moneyFormatter = bottomView.moneyFormatter else { return }
        let newText = moneyFormatter.format("\(amount ?? 0)") ?? ""
        bottomView.amountTextField.text = newText
        bottomView.doneButtonIsEnabled(newText.isEmpty)
    }
    
    func updateObjectWithNotification(cardId: Int? = nil) {
        var products: [UserAllCardsModel] = []
        let types: [ProductType] = [.card]
        types.forEach { type in
            products.append(contentsOf: self.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
        }
        
        let clientId = Model.shared.clientInfo.value?.id
        cardFromListView.cardList = products.filter({$0.ownerID == clientId})
        cardToListView.cardList = products
        cardFromField.getUImage = { self.model.images.value[$0]?.uiImage }

        if let cardId = cardId {
            
            let card = products.first(where: { $0.id == cardId })
            self.cardFromField.model = card
            self.viewModel.cardFromRealm = card
            
        } else {

            self.cardFromField.model = products.filter({$0.ownerID == Model.shared.clientInfo.value?.id}).first
            self.viewModel.cardFromRealm = products.filter({$0.ownerID == Model.shared.clientInfo.value?.id}).first
        }
    }
    
    private func updateCardsList(with result: Results<UserAllCardsModel>?) -> [UserAllCardsModel] {
        var cardsArray = [UserAllCardsModel]()
        result?.forEach { card in
            if card.productType == "CARD" {
                cardsArray.append(card)
            } else if !onlyCard && (card.productType == "ACCOUNT" || card.productType == "DEPOSIT" ) {
                cardsArray.append(card)
            }
        }
        return cardsArray
    }
    
    func setupActions() {
        
        seporatorView.buttonSwitchCardTapped = { () in
            guard let tmpModelFrom = self.cardFromField.model else { return }
            guard let tmpModelTo = self.cardToField.model else { return }
            self.cardFromField.model = tmpModelTo
            self.cardToField.model = tmpModelFrom
            self.viewModel.cardFromRealm = tmpModelTo
            self.viewModel.cardToRealm = tmpModelFrom
            
            self.bottomView.currencySymbol = tmpModelTo.currency?.getSymbol() ?? ""
            
            let tempBottomViewCurrencyFrom = self.bottomView.currencyFrom
            let tempBottomViewCurrencyTo = self.bottomView.currencyTo
            self.bottomView.currencyFrom = tempBottomViewCurrencyTo
            self.bottomView.currencyTo = tempBottomViewCurrencyFrom
            
            
            self.bottomView.currencyCode = tmpModelTo.currency ?? ""
            
            
            let text = self.bottomView.amountTextField.text
            let unformatText = self.bottomView.moneyFormatter?.unformat(text)
            self.bottomView.exchangeRate(unformatText ?? "")
            self.checkModel(with: self.viewModel)
        }
        
        bottomView.didDoneButtonTapped = { (amount) in
            self.doneButtonTapped(with: self.viewModel, amount: amount)
        }
    }
    
    private func setupFieldFrom() {
        cardFromField.titleLabel.text = "С карты"
        cardFromField.numberCardLabel.text = "Номер карты отправителя"
        cardFromField.didChooseButtonTapped = { [weak self]  () in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self?.cardFromListView.isHidden == true {
                        self?.cardFromListView.alpha = 1
                        self?.cardFromListView.isHidden = false
                    } else {
                        self?.cardFromListView.alpha = 0
                        self?.cardFromListView.isHidden = true
                    }
                    
                    self?.seporatorView.curvedLineView.isHidden.toggle()
                    self?.seporatorView.straightLineView.isHidden.toggle()
                    
                    if self?.cardToListView.isHidden == false {
                        self?.cardToListView.isHidden = true
                        self?.cardToListView.alpha = 0
                    }
                    self?.stackView.layoutIfNeeded()
                }
            }
        }
    }
    
    private func setupFieldTo() {
        cardToField.titleLabel.text = "На карту"
        cardToField.numberCardLabel.text = "Номер карты получателя"
        cardToField.didChooseButtonTapped = { [weak self]  () in
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self?.cardToListView.isHidden == true {
                        self?.cardToListView.alpha = 1
                        self?.cardToListView.isHidden = false
                    } else {
                        self?.cardToListView.alpha = 0
                        self?.cardToListView.isHidden = true
                    }
                    
                    if self?.cardFromListView.isHidden == false {
                        
                        self?.cardFromListView.isHidden = true
                        self?.cardFromListView.alpha = 0
                        
                        self?.seporatorView.curvedLineView.isHidden = false
                        self?.seporatorView.straightLineView.isHidden = true
                    }
                    self?.stackView.layoutIfNeeded()
                }
            }
        }
    }
    
    private func setupListFrom() {
        cardFromListView = CardsScrollView(onlyMy: onlyMy, onlyCard: true)
        
        cardFromListView.didCardTapped = { (cardId) in
            DispatchQueue.main.async {
                var products: [UserAllCardsModel] = []
                let types: [ProductType] = [.card]
                types.forEach { type in
                    products.append(contentsOf: self.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
                }
                products.forEach({ card in
                    if card.id == cardId {
                        self.viewModel.cardFromRealm = card
                        self.cardFromField.getUImage = { self.model.images.value[$0]?.uiImage }
                        self.cardFromField.model = card
                        self.bottomView.currencySymbol = card.currency?.getSymbol() ?? ""
                        UIView.animate(withDuration: 0.2) {
                            self.cardFromListView.isHidden = true
                            self.cardFromListView.alpha = 0
                            if self.cardToListView.isHidden == false {
                                self.cardToListView.isHidden = true
                            }
                            self.seporatorView.curvedLineView.isHidden = false
                            self.seporatorView.straightLineView.isHidden = true
                            
                            self.stackView.layoutIfNeeded()
                        }
                    }
                })
            }
        }
        cardFromListView.lastItemTap = {
            let vc = AllCardListViewController()
            vc.withTemplate = false
            if self.onlyMy {
                vc.onlyCard = false
            }
            vc.didCardTapped = { [weak self] card in
                self?.viewModel.cardFromRealm = card
                self?.cardFromField.getUImage = { self?.model.images.value[$0]?.uiImage }
                self?.cardFromField.model = card
                self?.bottomView.currencySymbol = card.currency?.getSymbol() ?? ""
                self?.hideAllCardList()
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
    }
    
    private func setupListTo() {
        cardToListView = CardsScrollView(onlyMy: onlyMy, onlyCard: true)
        cardToListView.canAddNewCard = onlyMy ? false : true
        
        cardToListView.firstItemTap = {
            self.view.addSubview(self.cardView)
            self.cardView.frame = self.view.bounds
            self.cardView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
            self.stackView.isHidden = true
            self.titleLabel.isHidden = true
            self.bottomView.isHidden = true
            self.hideAllCardList()
        }
        cardToListView.didCardTapped = { (cardId) in
            DispatchQueue.main.async {
                var products: [UserAllCardsModel] = []
                let types: [ProductType] = [.card]
                types.forEach { type in
                    products.append(contentsOf: self.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
                }
                products.forEach({ card in
                    if card.id == cardId {
                        self.viewModel.cardToRealm = card
                        self.cardToField.getUImage = { self.model.images.value[$0]?.uiImage }
                        self.cardToField.model = card
                        self.hideAllCardList()
                    }
                })
            }
        }
        cardToListView.lastItemTap = {
            let vc = AllCardListViewController()
            if self.onlyMy {
                vc.onlyCard = false
                vc.withTemplate = false
            }
            vc.didCardTapped = { [weak self] card in
                self?.viewModel.cardToRealm = card
                self?.cardToField.getUImage = { self?.model.images.value[$0]?.uiImage }
                self?.cardToField.model = card
                self?.hideAllCardList()
                vc.dismiss(animated: true, completion: nil)
            }
            vc.didTemplateTapped = { [weak self] card in
                self?.viewModel.customCardTo = CastomCardViewModel(cardNumber: card.numberMask ?? "", cardName: card.customName, cardId: card.id)
                self?.cardToField.tempCardModel = card
                self?.hideAllCardList()
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
    }
    
    private func checkModel(with model: ConfirmViewControllerModel) {
        guard model.cardFromRealm != nil, model.cardToRealm != nil else { return }
        // TODO: какие условия для смены местами: счет - счет, карта - карта?
        self.seporatorView.changeAccountButton.isHidden = true // TODO: для релиза отключена кнопка
        /// Когда скрывается кнопка смены валют, то есть валюта одинаковая, то меняем содеожание лейбла на то, что по умолчанию
        /// Если нет, то оправляем запрос на получения курса валют
        if self.bottomView.currencySwitchButton.isHidden == true {
            self.bottomView.buttomLabel.text = "Возможна комиссия ℹ︎"
        }
    }
       
    private func setupCardViewActions() {
        cardView.closeView = { [weak self] () in
//            self?.hideCustomCardView()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self?.cardView.alpha = 0
                    self?.stackView.isHidden = false
                    self?.titleLabel.isHidden = false
                    self?.bottomView.isHidden = false
                } completion: { finish in
                    if finish {
                        self?.cardView.removeFromSuperview()
                        self?.cardView.alpha = 1
                    }
                }
            }
        }
        cardView.finishAndCloseView = { [weak self]  (model) in
//            self?.hideCustomCardView()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self?.cardView.alpha = 0
                    self?.stackView.isHidden = false
                    self?.titleLabel.isHidden = false
                    self?.bottomView.isHidden = false
                } completion: { finish in
                    if finish {
                        self?.cardView.removeFromSuperview()
                        self?.cardView.alpha = 1
                    }
                    self?.viewModel.customCardTo = model
                    self?.cardToField.customCardModel = model
                }
            }
        }
    }
    
    private func hideCustomCardView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.cardView.alpha = 0
                self.stackView.isHidden = false
                self.titleLabel.isHidden = false
                self.bottomView.isHidden = false
            } completion: { finish in
                if finish {
                    self.cardView.removeFromSuperview()
                    self.cardView.alpha = 1
                }
            }
        }
    }
    
    private func hideAllCardList() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if self.cardFromListView.isHidden == false {
                    self.cardFromListView.isHidden = true
                    self.cardFromListView.alpha = 0
                }
                if self.cardToListView.isHidden == false {
                    self.cardToListView.isHidden = true
                    self.cardToListView.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - API
    
    func doneButtonTapped(with viewModel: ConfirmViewControllerModel, amount: String) {
        self.dismissKeyboard()
        self.showActivity()
        bottomView.doneButtonIsEnabled(true)
        let body = [ "check" : false,
                     "amount" : amount,
                     "currencyAmount" : self.bottomView.currencyCode,
                     "payer" : [
                        "cardId" : viewModel.cardFromCardId,
                        "cardNumber" : viewModel.cardFromCardNumber,
                        "accountId" : viewModel.cardFromAccountId,
                        "accountNumber" : viewModel.cardFromAccountNumber
                     ],
                     "payeeInternal" : [
                        "cardId" : viewModel.cardToCardId,
                        "cardNumber" : viewModel.cardToCardNumber,
                        "accountId" : viewModel.cardToAccountId,
                        "accountNumber" : viewModel.cardToAccountNumber,
                        "productCustomName" : viewModel.cardToCastomName
                     ] ] as [String : AnyObject]

        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            DispatchQueue.main.async {
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {
                        if let needMake = model.data?.needMake {
                            if needMake {
                                viewModel.taxTransction = "\(model.data?.fee ?? 0)"
                                viewModel.status = .succses
                                let vc = ContactConfurmViewController()
                                vc.getUImage = { self?.model.images.value[$0]?.uiImage }
                                vc.modalPresentationStyle = .fullScreen
                                vc.confurmVCModel?.type = .card2card
                                viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                viewModel.summInCurrency = model.data?.creditAmount?.currencyFormatter(symbol: model.data?.currencyPayee ?? "RUB") ?? ""
                                viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                viewModel.template = self?.paymentTemplate
                                vc.smsCodeField.isHidden = !(model.data?.needOTP ?? true)
                                vc.confurmVCModel = viewModel
                                vc.addCloseButton()
                                vc.title = "Подтвердите реквизиты"
                                let navVC = UINavigationController(rootViewController: vc)
                                navVC.modalPresentationStyle = .fullScreen
                                self?.present(navVC, animated: true)
                                
                            } else {
                                let vc = PaymentsDetailsSuccessViewController()
                                if model.data?.documentStatus == "COMPLETE" {
                                    viewModel.status = .succses
                                    viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    viewModel.paymentOperationDetailId = model.data?.paymentOperationDetailID ?? 0
                                    viewModel.template = self?.paymentTemplate
                                    vc.printFormType = "internal"
                                  
                                }
                                vc.confurmVCModel = viewModel
                                
                                let nav = UINavigationController(rootViewController: vc)
                                nav.modalPresentationStyle = .fullScreen
                                self?.present(nav, animated: true, completion: nil)
                            }
                        } else {
                            viewModel.status = .succses
                            let vc = PaymentsDetailsSuccessViewController()
                            vc.confurmVCModel = viewModel
//                            vc.modalPresentationStyle = .fullScreen
                            let nav = UINavigationController(rootViewController: vc)
                            nav.modalPresentationStyle = .fullScreen
                            self?.present(nav, animated: true, completion: nil)
                        }
                    } else {
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
}

