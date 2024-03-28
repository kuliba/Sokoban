//
//  MeToMeViewController.swift
//  ForaBank
//
//  Created by Mikhail on 09.08.2021.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

class MeToMeViewController: UIViewController {
    
    var meToMeContract: [FastPaymentContractFindListDatum]?
    var selectedBank: BankFullInfoList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }

    var banks: [BankFullInfoList] = [] {
        didSet {
            bankListView.bankList = banks
        }
    }
    var cardFromField: CardChooseView
    var cardListView = CardsScrollView(onlyMy: false, deleteDeposit: true, loadProducts: false)
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "В банка",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: true,
            showChooseButton: true)
    )
    var bankListView = FullBankInfoListView()
    var commentView = ForaInput(
        viewModel: ForaInputModel(
            title: "Комментарий",
            image: #imageLiteral(resourceName: "comment"))
    )
    var bottomView = BottomInputView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    //MARK: - Viewlifecicle
    init(cardFrom: UserAllCardsModel?, getUImage: @escaping (Md5hash) -> UIImage?) {
        cardFromField = CardChooseView()
        cardFromField.getUImage = getUImage
        cardFromField.model = cardFrom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    func setupUI() {
        view.backgroundColor = .white
        
        setupBottomView()
        setupStackView()
        setupCardFromView()
        setupActions()
//        setupPaymentsUI()
        setupCardList { [weak self] error in
            if error != nil {
                self?.showAlert(with: "Ошибка", and: error!)
            }
        }
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupStackView() {
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView,  bankField, bankListView, commentView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 20)
    }
    
    func setupPaymentsUI() {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0))
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Пополнить со счета\nв другом банке"
        self.navigationItem.titleView = label
        
        let navImage = UIImage(named: "logo-spb-mini")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .black
        subtitleLabel.font = .boldSystemFont(ofSize: 16)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        return titleView
    }
    
    private func setupCardFromView() {
        cardFromField.titleLabel.text = "Счет зачисления"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        cardFromField.didChooseButtonTapped = { () in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self.cardListView.isHidden == true {
                        self.cardListView.isHidden = false
                        self.cardListView.alpha = 1
                    } else {
                        self.cardListView.isHidden = true
                        self.cardListView.alpha = 0
                    }
                    if self.bankListView.isHidden == false {
                        self.bankListView.isHidden = true
                        self.bankListView.alpha = 0
                    }
                }
                self.stackView.layoutIfNeeded()
            }
        }
        
    }
    
    private func setupBottomView() {
        view.addSubview(bottomView)
        bottomView.currencySymbol = "₽"
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(
            top: view.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        bottomView.didDoneButtonTapped = { amount in
            self.showActivity()
            self.antiFraud { success, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.dismissActivity()
                        self.showAlert(with: "Ошибка", and: error ?? "")
                    } else {
                        if success {
                            guard let bank = self.selectedBank else {
                                self.dismissActivity()
                                self.showAlert(with: "Ошибка", and: "Выберите банк")
                                return
                            }
                            guard let cardModel = self.cardFromField.model else { return }
                            self.createMe2MePullTransfer(amount: amount, bank: bank.memberID!, cardModel: cardModel) { success, error in
                                DispatchQueue.main.async {
                                    if error != nil {
                                        self.dismissActivity()
                                        self.showAlert(with: "Ошибка", and: error ?? "")
                                    } else {
                                        if success {
                                            self.dismissActivity()
                                            let vc = SuccessMeToMeController.loadFromNib()
                                            
                                            let double = Double(amount) ?? 0
                                            let viewModel = SuccessMeToMeModel(amount: double, bank: bank)
                                            vc.viewModel = viewModel
                                            vc.modalPresentationStyle = .fullScreen
                                            self.present(vc, animated: true)
                                            
                                        } else {
                                            self.dismissActivity()
                                            self.showAlert(with: "Ошибка", and: "")
                                        }
                                    }
                                }
                            }
                        } else {
                            self.dismissActivity()
                            self.showAlert(with: "Ошибка", and: "")
                        }
                    }
                }
            }
        }
    }
    
    private func setupActions() {
        
        bankListView.didSeeAll = { () in self.openSearchBanksVC() }
        
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.bankListView.isHidden = true
                    self.bankListView.alpha = 0
                    if self.cardListView.isHidden == false {
                        self.cardListView.isHidden = true
                        self.cardListView.alpha = 0
                    }
                }
                self.stackView.layoutIfNeeded()
            }
        }
        
        bankField.didChooseButtonTapped = { () in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self.bankListView.isHidden == true {
                        self.bankListView.isHidden = false
                        self.bankListView.alpha = 1
                    } else {
                        self.bankListView.isHidden = true
                        self.bankListView.alpha = 0
                    }
                    if self.cardListView.isHidden == false {
                        self.cardListView.isHidden = true
                        self.cardListView.alpha = 0
                    }
                }
                self.stackView.layoutIfNeeded()
            }
        }
        
        bankField.didChangeValueField = { (field) in
            self.hideView(self.bankListView, needHide: false)
            self.bankListView.textFieldDidChanchedValue(textField: field)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let cardList = ReturnAllCardList.cards()
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.cardFromField.model = card
                    }
                })
                
                UIView.animate(withDuration: 0.2) {
                    self.bankListView.isHidden = true
                    self.bankListView.alpha = 0
                    if self.cardListView.isHidden == false {
                        self.cardListView.isHidden = true
                        self.cardListView.alpha = 0
                    }
                }
                self.stackView.layoutIfNeeded()
            }
        }
        
        self.banks = Model.shared.bankListFullInfo.value.map(\.fullBankInfoList)
    }
    
    private func openSearchBanksVC() {
        let vc = SearchBanksViewController()
        vc.banks = self.banks
        vc.didBankTapped = { (bank) in self.selectBank(bank: bank)}
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
    
    private func selectBank(bank: BankFullInfoList) {
        self.selectedBank = bank
        self.hideView(self.bankListView, needHide: true)
        self.hideView(self.cardListView, needHide: true)
    }
    
    
    private func setupBankField(bank: BankFullInfoList) {
        self.bankField.text = bank.fullName ?? ""
        
        if let imageString = bank.svgImage {
            self.bankField.imageView.image =  imageString.convertSVGStringToImage()
        } else {
            self.bankField.imageView.image = UIImage(named: "BankIcon")!
        }
    }
    
    private func setupCardList(completion: @escaping ( _ error: String?) ->() ) {
        
        DispatchQueue.main.async {
            
            let cards = ReturnAllCardList.cards()
            var filterProduct: [UserAllCardsModel] = []
            let clientId = Model.shared.clientInfo.value?.id

            cards.forEach({ card in
                if (card.productType == "CARD" || card.productType == "ACCOUNT") && card.ownerID == clientId {
                    if (card.productType == "CARD" || card.productType == "ACCOUNT" || card.productType == "DEPOSIT") && card.currency == "RUB" {
                        filterProduct.append(card)
                    }
                }
            })
            self.cardListView.cardList = filterProduct
            if filterProduct.count > 0 {
                if self.cardFromField.model == nil {
                    self.cardFromField.model = filterProduct.first
                }
                completion(nil)
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
    func suggestBank(_ bic: String, completion: @escaping (_ bankList: [BankFullInfoList]?, _ error: String?) -> Void ) {
        showActivity()
        
        let body = [ "bic": bic,
                     "serviceType" : "5",
                     "type": "20"
        ]
        
        NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList , body, [:]) { [weak self] model, error in
            self?.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                var filterBank: [BankFullInfoList] = []
                data.bankFullInfoList?.forEach({ bank in
                    if bank.senderList?.contains("ME2MEPULL") ?? false
                        && bank.receiverList?.contains("ME2MEPULL") ?? false {
                        filterBank.append(bank)
                    }
                })
                let list = filterBank.sorted(by: {$0.rusName ?? "" < $1.rusName ?? ""})
                completion(list, nil)
            } else {
                guard let error = model.errorMessage else { return }

                completion(nil, error)
            }
        }
    }
    
    func antiFraud(completion: @escaping (_ success: Bool, _ error: String?) -> Void ) {
        
        NetworkManager<AntiFraudDecodableModel>.addRequest(.antiFraud, [:], [:]) { model, error in
            if error != nil {
                guard let error = error else { return }
                completion(false, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                completion(data, nil)
            } else {
                guard let error = model.errorMessage else { return }

                completion(false, error)
            }
        }
    }
    
    func createMe2MePullTransfer(amount: String, bank: String, cardModel: UserAllCardsModel, completion: @escaping (_ success: Bool, _ error: String?) -> Void ) {
        
        var body = [ "amount" : amount,
                     "currencyAmount" : "RUB",
                     "comment" : "Перевод Me2Me Pull Credit",
                     "payer" : [ "cardId" : nil,
                                 "cardNumber" : nil,
                                 "accountId" : nil ],
                     "bankId" : bank ] as [String : AnyObject]
        if cardModel.productType == "CARD" {
            body["payer"] = ["cardId": cardModel.cardID,
                             "cardNumber" : nil,
                             "accountId" : nil] as AnyObject
        } else if cardModel.productType == "ACCOUNT" {
            body["payer"] = ["cardId": nil,
                             "cardNumber" : nil,
                             "accountId" : cardModel.id] as AnyObject
        } else if cardModel.productType == "DEPOSIT" {
            body["payer"] = ["cardId": nil,
                             "cardNumber" : nil,
                             "accountId" : cardModel.accountID] as AnyObject
        }
        
        NetworkManager<CreateFastPaymentContractDecodableModel>.addRequest(.createMe2MePullCreditTransfer, [:], body) { model, error in
            if error != nil {
                guard let error = error else { return }
                completion(false, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(true, nil)
            } else {
                guard let error = model.errorMessage else { return }

                completion(false, error)
            }
        }
        
    }
    
}
