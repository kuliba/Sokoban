//
//  MeToMeSettingViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.08.2021.
//

import UIKit
import Combine

class MeToMeSettingViewController: UIViewController {

    var newModel: Model = Model.shared
    var model: [FastPaymentContractFindListDatum]? {
        didSet {
            guard let model = model else { return }
            configure(with: model)
        }
    }
    
    private var bindings = Set<AnyCancellable>()
    
    var topSwitch = MeToMeSetupSwitchView()
    var cardFromField = CardChooseView()
    var cardListView = CardListView(onlyMy: false)
    var banksView: BanksView = BanksView()
    var defaultBank = DefaultBankView()
    var stackView = UIStackView(arrangedSubviews: [])
    var logo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "sfpBig"))

        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupPaymentsUI()
        setupStackView()
        setupTopSwitch()
        setupCardFromView()
        setupBankField()
        bind()
        
        setupCardList { [weak self] error in
            if error != nil {
                self?.showAlert(with: "Ошибка", and: error!)
            } else {
                self?.topSwitch.bankByPhoneSwitch.isEnabled = true
            }
        }
        
        cardListView.didCardTapped = { card in
            self.cardFromField.cardModel = card
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self.cardListView.isHidden == false {
                        self.cardListView.isHidden = true
                        self.cardListView.alpha = 0
                    }
                }
                self.stackView.layoutIfNeeded()
            }
            
            guard let contractId = self.model?.first?.fastPaymentContractAttributeList?.first else { return }
            self.showActivity()
            
            self.updateContract(contractId: contractId.fpcontractID,
                                cardModel: card,
                                isOff: true) { success, error in
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                } else {
                    self.dismissActivity()
                }
            }
        }
        
        getClientConsent { list, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                self.banksView.consentList = list
            }
        }
    }
    
    func bind() {
       
        newModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.FastPaymentSettings.ContractFindList.Response:
                    
                    switch payload.result {
                    case let .success(fastPaymentContractFullInfoType):
                        self.model = fastPaymentContractFullInfoType.map { $0.getFastPaymentContractFindListDatum() }
                    default: break
                    }
                    
                    self.dismissActivity()
                
                default: break
                }
        }.store(in: &bindings)
        
    }
    
    func configure(with model: [FastPaymentContractFindListDatum]) {
        if !model.isEmpty {
            let contract = model.first?.fastPaymentContractAttributeList?.first
            if contract?.flagClientAgreementIn == "YES"
                && contract?.flagClientAgreementOut == "YES" {
                
                topSwitch.configViewWithValue(true)
                banksView.isHidden = false
                cardFromField.isHidden = false
                defaultBank.isHidden = false
            } else {
                topSwitch.configViewWithValue(false)
                banksView.isHidden = true
                cardFromField.isHidden = true
                defaultBank.isHidden = true
            }
        } else {
            
            banksView.isHidden = true
            topSwitch.configViewWithValue(false)
            cardFromField.isHidden = true
            defaultBank.isHidden = true
        }
    }
    
    func setupStackView() {
        banksView.anchor(height: 150)
//        DispatchQueue.main.async {
//            self.banksView.sizeToFit()
//            self.banksView.content = { [weak self] height in
//                self?.banksView.anchor(height: height)
//            }
//            self.banksView.layoutIfNeeded()
//            self.banksView.sizeToFit()
//            self.stackView.layoutIfNeeded()
//            self.stackView.sizeToFit()
//            self.topSwitch.layoutIfNeeded()
//            self.topSwitch.sizeToFit()
//            self.cardFromField.layoutIfNeeded()
//            self.cardFromField.sizeToFit()
//            self.cardListView.layoutIfNeeded()
//            self.cardListView.sizeToFit()
//            self.defaultBank.layoutIfNeeded()
//            self.defaultBank.sizeToFit()
//
//        }
        
        stackView = UIStackView(arrangedSubviews: [topSwitch, cardFromField, cardListView, banksView, defaultBank])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor)
    }
   
    func setupPaymentsUI() {
        // настраиваем название контроллера в 2 строки
        self.navigationItem.titleView = setTitle(title: "Настройки СБП", subtitle: "Система быстрых платежей")
        // настраиваем логотип экрана
        view.addSubview(logo)
        logo.centerX(inView: view)
        logo.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 10)
    }
    
    func setTitle(title: String, subtitle: String) -> UIView {
        // создаем верхний UILabel
        let titleLabel = UILabel(text: title, font: .boldSystemFont(ofSize: 16), color: .black)
        // создаем нижний UILabel
        let subtitleLabel = UILabel(text: subtitle, font: .systemFont(ofSize: 12), color: .gray)
        
        // создаем контейнер для UILabeles
        let titleView = UIView(frame: .zero)
        
        // добавляем UILabeles в контейнер и настраиваем констрайнты
        titleView.addSubview(titleLabel)
        titleLabel.centerX(inView: titleView, topAnchor: titleView.topAnchor)
        titleView.addSubview(subtitleLabel)
        subtitleLabel.centerX(inView: titleView, topAnchor: titleLabel.bottomAnchor, paddingTop: 2)
        titleView.sizeToFit()
        titleView.anchor(left: subtitleLabel.leftAnchor, bottom: subtitleLabel.bottomAnchor, right: subtitleLabel.rightAnchor)
        return titleView
    }
    
    private func setupCardFromView() {
        // настройка поля с текущим счетом
        cardFromField.titleLabel.text = "Счет списания и зачисления"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        // действие по нажатию на поле с текущем счетом
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
            
        }
    }
    
    private func setupBankField() {
        // действие по нажатию на поле с банком
        banksView.didChooseButtonTapped = { () in
            let settingVC = MeToMeSearchBanksViewController()
            settingVC.rootVC = self
            let navVC = UINavigationController(rootViewController: settingVC)
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    private func setupCardList(after completion: @escaping ( _ error: String?) ->() ) {
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                if error != nil {
                    completion(error)
                }
                guard let data = data else { return }
                var filterProduct: [GetProductListDatum] = []
                data.forEach { product in
                    if (product.productType == "CARD" || product.productType == "ACCOUNT") && product.currency == "RUB" {
                        filterProduct.append(product)
                    }
                }
                
                self?.cardListView.cardList = filterProduct
                guard let contractId = self?.model?.first?.fastPaymentContractAttributeList?.first
                else { return }
                
                if filterProduct.count > 0 {
                    filterProduct.forEach { product in
                        if product.productType == "CARD" {
                            if product.accountID == contractId.accountID {
                                self?.cardFromField.cardModel = product
                            }
                        } else if product.productType == "ACCOUNT" {
                            if product.id == contractId.accountID {
                                self?.cardFromField.cardModel = product
                            }
                        }
                    }
                    completion(nil)
                }
            }
        }
    }
    
    func setupTopSwitch() {
        topSwitch.bankByPhoneSwitch.isEnabled = false
        
        topSwitch.switchIsChanged = { (sender) in
            self.showActivity()
            guard let model = self.model else { return }
            self.banksView.isHidden = !sender.isOn
            
            if model.isEmpty {
                
                self.createContract(cardModel: self.cardFromField.cardModel!) { success, error in
                    
                    DispatchQueue.main.async {
                        self.dismissActivity()
                        self.hideView(self.cardFromField, needHide: !sender.isOn) {
                            if !self.cardListView.isHidden {
                                self.hideView(self.cardListView, needHide: true) { }
                            }
                        }
                        self.newModel.action.send(ModelAction
                                                 .FastPaymentSettings
                                                 .ContractFindList.Request())
                    }
                }
            } else {
                guard let contractId = self.model?.first?.fastPaymentContractAttributeList?.first else { return }
                
                self.updateContract(contractId: contractId.fpcontractID,
                                    cardModel: self.cardFromField.cardModel!,
                                    isOff: sender.isOn) { success, error in
                    
                    DispatchQueue.main.async {
                        self.dismissActivity()
                        self.hideView(self.cardFromField, needHide: !sender.isOn) {
                            if !self.cardListView.isHidden {
                                self.hideView(self.cardListView, needHide: true) { }
                            }
                        }
                        self.newModel.action.send(ModelAction
                                                 .FastPaymentSettings
                                                 .ContractFindList.Request())
                    }
                }
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
            }
        }
    }
    
    func hideView(_ view: UIView, needHide: Bool, completion: @escaping () -> Void ) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
            }
        }
        completion()
    }
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
       
        let cardList = newModel.products.value
            .filter { $0.key == .card || $0.key == .account }
            .values.flatMap { $0 }
            .map { $0.getProductListDatum() }
        
        completion(cardList, nil)
    }
    
    func updateContract(contractId: Int?, cardModel: GetProductListDatum, isOff: Bool ,completion: @escaping (_ success: Bool, _ error: String?)->()) {
        guard let fpcontractID = contractId else { return }
        
        var body = [ "contractId"               : fpcontractID,
                     "cardId"                   : nil,
                     "accountId"                : nil,
                     "flagBankDefault"          : "EMPTY",
                     "flagClientAgreementIn"    : isOff ? "YES" : "NO",
                     "flagClientAgreementOut"   : isOff ? "YES" : "NO"
        ] as [String : AnyObject]
        
        if cardModel.productType == "CARD" {
            body["cardId"] = cardModel.id as AnyObject?
        } else if cardModel.productType == "ACCOUNT" {
            body["accountId"] = cardModel.id as AnyObject?
        }
        
        NetworkManager<UpdateFastPaymentContractDecodableModel>.addRequest(.updateFastPaymentContract, [:], body) { model, error in
            if error != nil {
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
    
    func createContract(cardModel: GetProductListDatum, completion: @escaping (_ success: Bool, _ error: String?)->()) {
        guard let accountId = cardModel.ownerID else { return }
        let body = [ "accountId"                : accountId,
                     "flagBankDefault"          : "YES",
                     "flagClientAgreementIn"    : "YES",
                     "flagClientAgreementOut"   : "YES"
        ] as [String : AnyObject]
        
        NetworkManager<CreateServiceTransferDecodableModel>.addRequest(.createFastPaymentContract, [:], body) { model, error in
            if error != nil {
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
    
    func getClientConsent(completion: @escaping (_ bankList: [ConsentList]?, _ error: String?) -> Void) {
        showActivity()
        NetworkManager<GetClientConsentMe2MePullDecodableModel>.addRequest(.getClientConsentMe2MePull, [:], [:]) { [weak self] model, error in
            self?.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                completion(data.consentList ?? [], nil)
            } else {
                guard let error = model.errorMessage else { return }

                completion(nil, error)
            }
        }
    }
    
}
