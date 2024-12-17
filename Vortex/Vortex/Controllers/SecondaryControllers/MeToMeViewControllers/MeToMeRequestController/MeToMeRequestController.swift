//
//  MeToMeRequestController.swift
//  ForaBank
//
//  Created by Mikhail on 30.08.2021.
//

import UIKit

class MeToMeRequestController: UIViewController {

    var viewModel: RequestMeToMeModel? {
        didSet {
            guard let model = self.viewModel else { return }
            fillData(model: model)
        }
    }
    
    private let model: Model = .shared
    
    var nextStep = false
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 30)
    
    // MARK: - Views
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.frame = self.view.bounds
        view.contentSize = contentViewSize
        view.autoresizingMask = .flexibleHeight
        view.showsHorizontalScrollIndicator = true
        view.bounces = true
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame.size = contentViewSize
        return view
    }()
    
    lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular_Medium", size: 18)
        label.text = "Вы запросили перевод на свой счет"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    lazy var labelSubTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 14)
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false))
    
    lazy var cardFromField: CardChooseView = {
       let cardField = CardChooseView()
        cardField.getUImage = { self.model.images.value[$0]?.uiImage }
        cardField.titleLabel.text = "Счет списания"
        cardField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardField.imageView.isHidden = false
        cardField.choseButton?.isHidden = true
        cardField.leftTitleAncor.constant = 64
        cardField.layoutIfNeeded()
        return cardField
    }()
    
    lazy var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: UIImage(named: "coins")!,
            isEditable: false))
    
    lazy var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    lazy var fpsSwitch: UIView = {
        let view = UIView()
        var topSwitch = MeToMeReqestSwitchView()
        view.addSubview(topSwitch)
        topSwitch.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        topSwitch.layer.cornerRadius = 8
        topSwitch.clipsToBounds = true
        return view
    }()
    
    lazy var tarifView: UIView = {
        let view = UIView()
        let tarifView = TarifView()
        view.addSubview(tarifView)
        tarifView.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingLeft: 20, paddingRight: 20)
        tarifView.viewDidTapped = { () in self.tariffButtonTapped() }
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(
            title: "Отменить", titleColor: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1),
            backgroundColor: .white, isBorder: true, borderColor: #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1))
        button.addTarget(self, action:#selector(cancelButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(title: "Перевести")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        addCloseButton()
        let navImage = UIImage(named: "logo-spb-mini")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
        checkAuth { error in
            if error != nil {
//                self.goToPinVC(.validate)
            } else {
                DispatchQueue.main.async {
                    self.nextButton.isEnabled = true
                    self.cancelButton.isEnabled = true
                }
            }
        }
        
    }
    
    func fillData(model: RequestMeToMeModel) {
        summTransctionField.text = model.amount.currencyFormatter(symbol: "RUB")
        taxTransctionField.text = model.fee.currencyFormatter(symbol: "RUB")
        let bank = findBank(bankId: model.bank)
        bankField.text = bank?.memberNameRus ?? ""
        bankField.imageView.image = bank?.svgImage.uiImage
        labelSubTitle.text = "Денежные средства будут списываться по вашим запросам из \(bank?.memberNameRus ?? "") без подтверждения?"
        labelSubTitle.isHidden = true
        let cardId = model.userInfo?["cardId"] as? String ?? ""
        let accountId = model.userInfo?["accountId"] as? String ?? ""
        if let cardValue = findProduct(with: Int(cardId), with: Int(accountId)) {

            cardFromField.model = cardValue
        }
    }
    
    func findBank(bankId: String?) -> BankData? {
        
        guard let bankId else {
            return nil
        }
        
        let bank = Model.shared.dictionaryBank(for: bankId)
        return bank
    }
    
    func cards() ->  [UserAllCardsModel] {

        var products: [UserAllCardsModel] = []
        let types: [ProductType] = [.card, .account]
        types.forEach { type in

            products.append(contentsOf: AppDelegate.shared.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
        }

        return products
    }
    
    private func findProduct(with cardId: Int?, with accountId: Int?) -> UserAllCardsModel? {
        let cardList = cards()
        var card: UserAllCardsModel?
        cardList.forEach { product in
            if cardId != nil {
                if product.id == cardId {
                    card = product
                }
            } else {
                if product.id == accountId {
                    card = product
                }
            }
        }
        if card == nil {
            card = cardList.first
        }
        return card
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        let topView = UIView()
        let labelImage = UIImageView(image: UIImage(named: "incomeMeToMe"))
        topView.addSubview(labelImage)
        topView.setDimensions(height: 72, width: 72)
        topView.backgroundColor = #colorLiteral(red: 1, green: 0.6547051072, blue: 0.2695361376, alpha: 1)
        topView.layer.cornerRadius = 36
        topView.clipsToBounds = true
        labelImage.setDimensions(height: 48, width: 48)
        labelImage.center(inView: topView)
        
        let stackView = UIStackView(
            arrangedSubviews: [bankField, cardFromField, summTransctionField, taxTransctionField, fpsSwitch, tarifView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        
        let buttonSteck = UIStackView(arrangedSubviews: [cancelButton, nextButton])
        buttonSteck.axis = .horizontal
        buttonSteck.alignment = .fill
        buttonSteck.distribution = .fillEqually
        buttonSteck.spacing = 16
        
        containerView.addSubview(topView)
        containerView.addSubview(labelTitle)
        containerView.addSubview(labelSubTitle)
        containerView.addSubview(stackView)
        view.addSubview(buttonSteck)
        
        topView.centerX(
            inView: view, topAnchor: containerView.topAnchor, paddingTop: 30)
        
        labelTitle.centerX(
            inView: view, topAnchor: topView.bottomAnchor, paddingTop: 24)
        
        labelTitle.anchor(
            left: view.leftAnchor, right: view.rightAnchor,
            paddingLeft: 20, paddingRight: 20)
        
        labelSubTitle.centerX(
            inView: view, topAnchor: labelTitle.bottomAnchor, paddingTop: 24)
        
        labelSubTitle.anchor(
            left: view.leftAnchor, right: view.rightAnchor,
            paddingLeft: 20, paddingRight: 20)
        
        stackView.anchor(
            top: labelSubTitle.bottomAnchor, left: containerView.leftAnchor,
            right: containerView.rightAnchor, paddingTop: 20)
        
        buttonSteck.anchor(
            left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
            paddingRight: 20, height: 44)
        
    }
    
    //MARK: - Actions
    @objc func doneButtonTapped() {
//        
        if nextStep {
            showActivity()
            createPermanentConsentMe2Me { error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.dismissActivity()
                        self.showAlert(with: "Ошибка", and: error!) {
                            NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                        }
                    }
                } else {
                    if self.viewModel?.amount != 0 {
                        self.createMe2MePullDebit { error in
                            DispatchQueue.main.async {
                                self.dismissActivity()
                                if error != nil {
                                    self.showAlert(with: "Ошибка", and: error!) {
                                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                                    }
                                } else {
                                    self.showAlert(with: "Удачно", and: "Ваши деньги зачислены") {
                                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                                    }
                                }
                            }
                        }
                    } else {
                        self.dismissActivity()
                        self.showAlert(with: "Готово", and: "") {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                            }
                        }
                    }
                }
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.labelSubTitle.isHidden = false
                self.bankField.isHidden = true
                self.summTransctionField.isHidden = true
                self.taxTransctionField.isHidden = true
//                self.fpsSwitch.isHidden = true
//                self.tarifView.isHidden = true
                self.labelTitle.text = "Переводить без подтверждения?"
                self.nextButton.setTitle("Да", for: .normal)
                self.cancelButton.setTitle("Пока нет", for: .normal)
                
            }
            nextStep = true
        }
    }
    
    @objc func cancelButtonTapped() {
        
        if nextStep {
            self.showActivity()
            createIsOneTimeConsentMe2Me { error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.dismissActivity()
                        self.showAlert(with: "Ошибка", and: error!) {
                            NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                        }
                    } else {
                        if self.viewModel?.amount != 0 {
                            self.createMe2MePullDebit { error in
                                DispatchQueue.main.async {
                                    self.dismissActivity()
                                    if error != nil {
                                        self.showAlert(with: "Ошибка", and: error!){
                                            NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                                        }
                                    } else {
                                        self.showAlert(with: "Удачно", and: "Ваши деньги зачислены") {
                                            NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                                        }
                                    }
                                }
                            }
                        } else {
                            self.dismissActivity()
                            self.showAlert(with: "Готово", and: "") {
                                self.dismiss(animated: true, completion: nil)
                                    NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                            }
                        }
                    }
                }
            }
        } else {
            NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
        }
    }
    
    @objc func tariffButtonTapped() {
        
    }
    
    //MARK: - API
    private func checkAuth(completion: @escaping (_ error: String?) -> () ) {
        NetworkManager<IsLoginDecodableModel>.addRequest(.isLogin, [:], [:]) { model, error in
            if error != nil {
                completion(error)
            }
            if model?.statusCode == 0 {
                completion(nil)
            } else {
                guard let error = model?.errorMessage else { return }
                completion(error)
            }
        }
    }
    
    private func createIsOneTimeConsentMe2Me(completion: @escaping (_ error: String?) -> () ) {
        guard let memberID = viewModel?.bank else { return }
        let body = ["bankId": memberID] as [String : AnyObject]
        NetworkManager<CreateIsOneTimeConsentMe2MePullDecodableModel>.addRequest(.createIsOneTimeConsentMe2MePull, [:], body) { model, error in
            if error != nil {
                completion(error)
            }
            if model?.statusCode == 0,
               model?.errorMessage == nil {
                
                completion(nil)
            } else {
                guard let error = model?.errorMessage else { return }
                completion(error)
            }
        }
    }
    
    private func createPermanentConsentMe2Me(completion: @escaping (_ error: String?) -> () ) {
        guard let memberID = viewModel?.bank else { return }
        let body = ["bankId": memberID] as [String : AnyObject]
        NetworkManager<CreatePermanentConsentMe2MePullDecodableModel>.addRequest(.createPermanentConsentMe2MePull, [:], body) { model, error in
            if error != nil {
                completion(error)
            }
            if model?.statusCode == 0,
               model?.errorMessage == nil {
                
                completion(nil)
            } else {
                guard let error = model?.errorMessage else { return }
                completion(error)
            }
        }
    }
    
    private func createMe2MePullDebit(completion: @escaping (_ error: String?) -> ()) {
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            guard let bankRecipientID = viewModel.bank else { return }
            guard let card = viewModel.card else { return }
            
            var body = [
                "check" : false,
                "amount" : viewModel.amount,
                "currencyAmount" : "RUB",
                "payer" : ["cardId" : nil,
                           "cardNumber" : nil,
                           "accountId" : nil],
                "puref" : "iFora||TransferC2CSTEP",
                "additional" :
                    [["fieldid": 1, "fieldname": "RecipientID",     "fieldvalue": viewModel.RecipientID],
                     ["fieldid": 2, "fieldname": "BankRecipientID", "fieldvalue": bankRecipientID],
                     ["fieldid": 3, "fieldname": "RcvrMsgId",       "fieldvalue": viewModel.RcvrMsgId],
                     ["fieldid": 4, "fieldname": "RefTrnId",        "fieldvalue": viewModel.RefTrnId]
                    ] ] as [String : AnyObject]
                        
            if card.productType == "CARD" {
                
                body["payer"] = ["cardId": card.cardID,
                                 "cardNumber" : nil,
                                 "accountId" : nil] as AnyObject
                
            } else if card.productType == "ACCOUNT" {
                
                body["payer"] = ["cardId": nil,
                                 "cardNumber" : nil,
                                 "accountId" :  card.id] as AnyObject
            }
            
            NetworkManager<CreateMe2MePullDebitTransferDecodableModel>.addRequest(.createMe2MePullDebitTransfer, [:], body) { transferModel, error in
                if error != nil {
                    completion(error)
                }
                if transferModel?.statusCode == 0,
                   transferModel?.errorMessage == nil {
                    
                    NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], [:]) { model, error in
                        self.dismissActivity()
                        if error != nil {
                            completion(error)
                        } else if model?.statusCode == 0 {
                            completion(nil)
                        } else {
                            guard let error = model?.errorMessage else { return }
                            completion(error)
                        }
                    }
                } else {
                    guard let error = transferModel?.errorMessage else { return }
                    completion(error)
                }
            }
        }
    }
    
}
