//
//  TransferByRequisitesViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 30.06.2021.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

struct Fio {
    var name, patronymic, surname: String
}

class TransferByRequisitesViewController: UIViewController, UITextFieldDelegate, MyProtocol {
    
    let model: Model = .shared
    var cardIsSelect = false
    
    var byCompany = false
    var paymentTemplate: PaymentTemplateData? = nil
    var viewModel = ConfirmViewControllerModel(type: .requisites, status: .succses)
    var selectedBank: BankFullInfoList? {
        didSet {
            guard let bank = selectedBank else {
                return
            }
            setupBankField(bank: bank)
        }
    }
    
    var banks: [BankFullInfoList] = [] {
        didSet {
            bankListView.bankList = banks
        }
    }
    var bankListView = FullBankInfoListView()
    
    private func setupBankField(bank: BankFullInfoList) {
        self.bikBankField.text = bank.bic ?? "" //"АйДиБанк"
        
        if let imageString = bank.svgImage {
            self.bikBankField.imageView.image = imageString.convertSVGStringToImage()
        } else {
            self.bikBankField.imageView.image = UIImage(named: "BankIcon")!
        }
    }
    
    var selectedCardNumber: String?
    var payerINN = "0"
    
    var bottomView = BottomInputView()
    
    var bikBankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Бик банка получателя",
            image: #imageLiteral(resourceName: "bikbank"),
            type: .number,
            showChooseButton: true))
    
    var accountNumber = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер счета получателя",
            image: #imageLiteral(resourceName: "accountIcon"),
            type: .number))
    
    var fioField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "person"),
            showChooseButton: true))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя"))
    
    var surField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество"))
    
    var commentField = ForaInput(
        viewModel: ForaInputModel(
            title: "Назначение платежа",
            image: #imageLiteral(resourceName: "comment"),
            errorText: "Укажите дополнительную информацию. Не менее 25 символов"))
    
    var innField = ForaInput(
        viewModel: ForaInputModel(
            title: "ИНН получателя",
            type: .number))
    
    var nameCompanyField = ForaInput(
        viewModel: ForaInputModel(
            title: "Наименование получателя",
            errorText: "Укажите название организации"))
    
    var kppField = ForaInput(
        viewModel: ForaInputModel(
            title: "КПП получателя",
            type: .number,
            errorText: "Необязательное поле"))
    
    var cardField = CardChooseView()
    var cardListView = CardsScrollView(onlyMy: true, deleteDeposit: true)
    var stackView = UIStackView(arrangedSubviews: [])
    var fioStackView = UIStackView(arrangedSubviews: [])
    var fio = Fio(name: "", patronymic: "", surname: "") {
        didSet {
            if fio.name != "" && fio.patronymic != "" && fio.surname != "" {
                //                self.commentField.isHidden = false
                //                self.stackView.addSubview(commentField)
            }
        }
    }
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func presentScanner() {
        PermissionHelper.checkCameraAccess(isAllowed: { granted, alert in
            if granted {
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        let controller = QRViewController.storyboardInstance()!
                        controller.segueOut = false
                        let nc = UINavigationController(rootViewController: controller)
                        nc.modalPresentationStyle = .fullScreen
                        self.present(nc, animated: true)
                        
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if let alertUnw = alert {
                        self.present(alertUnw, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    var delegate: MyProtocol?
    
    
    func checkQREvent() {
        if GlobalModule.qrOperator != nil && GlobalModule.qrData != nil {
            if let controller = InternetTVMainController.storyboardInstance()  {
                let nc = UINavigationController(rootViewController: controller)
                self.modalPresentationStyle = .fullScreen
                present(nc, animated: false)
            }
        }
    }
    
    //MARK: - Viewlifecicle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(paymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = paymentTemplate
        if let parameter = paymentTemplate.parameterList.first as? TransferGeneralData {
            
            if let bik = parameter.payeeExternal?.bankBIC {
                bikBankField.textField.text = bik
            }
            
            if let account = parameter.payeeExternal?.accountNumber {
                let mask = StringMask(mask: "00000 000 0 0000 0000000")
                accountNumber.textField.text = mask.mask(string: account)
            }
            
            if let fullName = parameter.payeeExternal?.name {
                let full = fullName.components(separatedBy: " ")
                fio.surname = full[0]
                fioField.textField.text = full[0]
                
                fio.name = full[1]
                nameField.textField.text = full[1]
                
                fio.patronymic = full[2]
                surField.textField.text = full[2]
            }
            
            if let inn = parameter.payeeExternal?.inn {
                innField.textField.text = inn
            }
            
            if let kpp = parameter.payeeExternal?.kpp {
                kppField.textField.text = kpp
            }
        }
    }
    
    init(orgPaymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = orgPaymentTemplate
        if let parameter = orgPaymentTemplate.parameterList.first as? TransferGeneralData {
            
            self.byCompany = true
            self.stackView.removeArrangedSubview(self.fioField)
            self.fioField.isHidden = true
            self.stackView.removeArrangedSubview(self.nameField)
            self.nameField.isHidden = true
            self.stackView.removeArrangedSubview(self.surField)
            self.surField.isHidden = true
            
            self.stackView.addArrangedSubview(self.innField)
            self.innField.isHidden = false
            
            self.stackView.addArrangedSubview(self.kppField)
            self.kppField.isHidden = false
            
            self.stackView.addArrangedSubview(self.commentField)
            self.commentField.isHidden = false
            
            self.stackView.addArrangedSubview(self.nameCompanyField)
            self.nameCompanyField.isHidden = false
            
            if let bik = parameter.payeeExternal?.bankBIC {
                bikBankField.text = bik
                bikBankField.textField.text = bik
            }
            let mask = StringMask(mask: "00000 000 0 0000 0000000")
            
            if let account = parameter.payeeExternal?.accountNumber,
                let accountMasked = mask.mask(string: account) {
                
                accountNumber.text = accountMasked
                accountNumber.textField.text = accountMasked
            }
            
            if let fullName = parameter.payeeExternal?.name,
                let inn = parameter.payeeExternal?.inn,
                let kpp = parameter.payeeExternal?.kpp {

                sendData(kpp: kpp, name: fullName)
                innField.textField.text = inn
                innField.text = inn
            }
            if let comment = parameter.comment {
                commentField.text = comment
                commentField.textField.text = comment
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkQREvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let template = paymentTemplate {
            runBlockAfterDelay(0.2) {
                self.setupAmount(amount: template.amount)
                self.accountNumberFieldDidChange()
                
                if self.byCompany == false {
                    
                    self.hideShowFields()
                } else {
                    self.innFieldDidChange()
                }
            }
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCard()
        setupUI()
        setupActions()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func sendData(kpp: String, name: String) {
        
        kppField.text = kpp
        nameCompanyField.text = name
        nameCompanyField.textField.text = name
    }
    
    func loadCard() {
        DispatchQueue.main.async {
            var filterProduct: [UserAllCardsModel] = []
            let cards = ReturnAllCardList.cards()
            cards.forEach { product in
                if (product.productType == "CARD"
                        || product.productType == "ACCOUNT") && product.currency == "RUB" {
                    filterProduct.append(product)
                }
            }

            if filterProduct.count > 0 {
                if let cardId = self.paymentTemplate?.parameterList.first?.payer?.cardId {
                    let card = filterProduct.first(where: { $0.id == cardId })
                    self.cardField.model = card
                    guard let cardNumber = card?.number else { return }
                    self.selectedCardNumber = cardNumber
                    self.cardIsSelect = true
                } else {
                    self.cardField.model = filterProduct.first
                    guard let cardNumber = filterProduct.first?.number else {
                        return
                    }
                    self.selectedCardNumber = cardNumber
                    self.cardIsSelect = true
                }
        }
    }
    }
    
    //MARK: - Actions
    
    func setupActions() {
        setupFieldsActions()
        setupBanksActions()
        setupCardsAction()
        setupBottomViewAction()
    }
    
    func setupFieldsActions() {
        fioField.didChangeValueField = { (field) in
            if self.nameField.isHidden == true {
                self.fioField.textField.text = self.fio.surname + self.fio.patronymic + self.fio.name
            } else {
                self.fio.surname = self.fioField.textField.text ?? ""
            }
        }
        
        fioField.didChooseButtonTapped = { () in
            self.hideShowFields()
            if self.fioField.textField.text?.count != 0 {
                self.fioField.textField.text = self.fio.surname
            } else {
                self.fioField.textField.text = self.fio.surname
            }
            if self.nameField.isHidden || self.nameField.textField.text == "" {
                self.fio.name = self.nameField.textField.text ?? ""
                self.fio.patronymic = self.surField.textField.text ?? ""
                self.fio.surname = self.fioField.textField.text ?? ""
                self.fioField.textField.text = self.fio.surname + " " + self.fio.name + " " + self.fio.patronymic
            }
        }
        
        surField.didChangeValueField = { (field) in
            
        }
        
        accountNumber.didChangeValueField = { (field) in
            self.accountNumberFieldDidChange()
        }
        
        bikBankField.didChangeValueField = { (field) in
            self.hideView(self.bankListView, needHide: false)
            self.bankListView.textFieldDidChanchedValue(textField: field)
        }
        
        bikBankField.didChooseButtonTapped = { () in
            UIView.animate(withDuration: 0.2) {
                self.openOrHideView(self.bankListView)
            }
        }
        
        innField.didChangeValueField = { (field) in
            self.innFieldDidChange()
        }
    }
    
    func innFieldDidChange() {
        if self.innField.textField.text?.count == 10 || self.innField.textField.text?.count == 12 {
            self.suggestCompany()
        } else {
            self.nameField.isHidden = true
            self.kppField.isHidden = true
            self.nameCompanyField.isHidden = true
            self.commentField.isHidden = true
        }
    }
    
    func accountNumberFieldDidChange() {
        self.accountNumber.textField.maskString = "00000 000 0 0000 0000000"
        if self.accountNumber.textField.text?.replacingOccurrences(of: " ", with: "").count == 20,
            self.accountNumber.textField.text?.prefix(5) == "40817" ||
            self.accountNumber.textField.text?.prefix(5) == "40820" ||
            self.accountNumber.textField.text?.prefix(3) == "423" ||
            self.accountNumber.textField.text?.prefix(3) == "426" {
            
            self.stackView.addArrangedSubview(self.fioField)
            self.byCompany = false
            self.fioField.isHidden = false
        } else if self.accountNumber.textField.text?.replacingOccurrences(of: " ", with: "").count == 20 {
            
            self.byCompany = true
            self.fio.name.removeAll()
            self.fio.patronymic.removeAll()
            self.fioField.textField.text = ""
            self.fio.surname.removeAll()
            self.stackView.addArrangedSubview(self.innField)
            self.innField.isHidden = false
        } else {
            
            self.fioField.isHidden = true
            self.nameField.isHidden = true
            self.surField.isHidden = true
            self.commentField.isHidden = true
            self.innField.isHidden = true
            self.kppField.isHidden = true
            self.nameCompanyField.isHidden = true
            self.stackView.removeArrangedSubview(self.innField)
            self.stackView.removeArrangedSubview(self.nameCompanyField)
            self.stackView.removeArrangedSubview(self.kppField)
            self.stackView.removeArrangedSubview(self.fioField)
            self.stackView.removeArrangedSubview(self.nameField)
            self.stackView.removeArrangedSubview(self.surField)
            self.stackView.removeArrangedSubview(self.commentField)
        }
    }
    
    func setupBanksActions() {
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
            self.hideView(self.bankListView, needHide: true)
            self.hideView(self.cardListView, needHide: true)
        }
        
        bankListView.didBankTapped = { (bank) in
            self.selectBank(bank: bank)
        }
        
        bankListView.didSeeAll = { () in
            self.openSearchBanksVC()
        }
        
        suggestBank("") { model in
            self.banks = model
        }
    }
    
    func setupCardsAction() {
        
        cardField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
            self.hideView(self.bankListView, needHide: true)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                
                var products: [UserAllCardsModel] = []
                
                let data = self.model.products.value
                
                products = data.flatMap({$0.value}).map({$0.userAllProducts()})
                
                products.forEach({ card in
                    if card.id == cardId {
                        self.cardField.model = card
                        self.selectedCardNumber = String(card.cardID)
                        if self.bankListView.isHidden == false {
                            self.hideView(self.bankListView, needHide: true)
                        }
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                    }
                })
            }
        }
    }
    
    func setupBottomViewAction() {
        bottomView.didDoneButtonTapped = { (amount) in
            self.prepareExternal()
        }
        
        bottomView.didDoneButtonTapped = { [weak self] (amount) in
            self?.doneButtonTapped()
        }
    }
    
    func hideShowFields() {
        let model = ForaInputModel(
            title: "Фамилия",
            image: #imageLiteral(resourceName: "person"),
            showChooseButton: true)
        fioField.viewModel = model
        //            self.fioField.placeHolder.text = "Фамилия"
        nameField.isHidden.toggle()
        if nameField.isHidden == true {
            let model = ForaInputModel(
                title: "ФИО получателя",
                image: #imageLiteral(resourceName: "person"),
                showChooseButton: true)
            
            fioField.viewModel = model
        }
        surField.isHidden.toggle()
        stackView.insertArrangedSubview(nameField, at: 6)
        stackView.insertArrangedSubview(surField, at: 7)
    }
    
    @objc func myTargetFunction(textField: UITextField) {
        if nameField.isHidden == true {
            hideShowFields()
        }
    }
    
    private func openSearchBanksVC() {
        let vc = SearchBanksViewController()
        vc.banks = banks
        vc.didBankTapped = { (bank) in
            self.selectBank(bank: bank)
        }
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
    private func selectBank(bank: BankFullInfoList) {
        selectedBank = bank
        hideView(bankListView, needHide: true)
        hideView(cardListView, needHide: true)
    }
    
    @objc func onTouchBackButton() {
            viewModel.closeAction()
            dismiss(animated: true)
            navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        
        if paymentTemplate != nil {
            
            let button = UIBarButtonItem(image: UIImage(named: "back_button"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(onTouchBackButton))
            button.tintColor = .black
            navigationItem.leftBarButtonItem = button
            
        } else {
            
            let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(onTouchBackButton))
            button.tintColor = .black
            navigationItem.leftBarButtonItem = button
        }
        
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(bottomView)
        
        self.navigationItem.titleView = setTitle(title: "Перевести", subtitle: "Человеку или организации")
        self.navigationController?.navigationBar.backgroundColor = .white
        
        //        bottomView.currencySymbol = "₽"
        
        let item = UIBarButtonItem(image: UIImage.init(imageLiteralResourceName: "scanner"), style: .plain, target: self, action: #selector(presentScanner))
        item.tintColor = .black
        item.isEnabled = true
        navigationItem.setRightBarButton(item, animated: false)
        
        nameCompanyField.errorLabel.sizeToFit()
        nameCompanyField.errorLabel.isHidden = false
        nameCompanyField.errorLabel.alpha = 1
        nameCompanyField.errorLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        kppField.errorLabel.sizeToFit()
        kppField.errorLabel.isHidden = false
        kppField.errorLabel.alpha = 1
        kppField.errorLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        commentField.errorLabel.alpha = 1
        commentField.errorLabel.isHidden = false
        commentField.errorLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        innField.errorLabel.isHidden = true
        innField.errorLabel.alpha = 0
        
        nameField.isHidden = true
        
        surField.isHidden = true
        
        fioField.chooseButton.setImage(UIImage(imageLiteralResourceName: "extensionButton"), for: .normal)
        fioField.textField.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        
        fioStackView = UIStackView(arrangedSubviews: [fioField, nameField, surField])
        fioStackView.axis = .vertical
        fioStackView.alignment = .fill
        fioStackView.distribution = .equalSpacing
        fioStackView.spacing = 20
        fioStackView.isUserInteractionEnabled = true
        
        stackView = UIStackView(arrangedSubviews: [bikBankField, bankListView, accountNumber, cardField, cardListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        setupConstraint()
    }
    
    func setupAmount(amount: Double?) {
        guard let moneyFormatter = bottomView.moneyFormatter else { return }
        let newText = moneyFormatter.format("\(amount ?? 0)") ?? ""
        bottomView.amountTextField.text = newText
        bottomView.doneButtonIsEnabled(newText.isEmpty)
    }
    
    func setuoUIByCompany() {
        stackView.addArrangedSubview(innField)
    }
    
    func setupConstraint() {
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20)
    }
    
    @objc func doneButtonTapped() {
        prepareExternal()
    }
    
    func setTitle(title: String, subtitle: String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        return titleView
    }
    
    //MARK: - Animations
    
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
    
    //MARK: - API
    
    func suggestBank(_ bic: String, completion: @escaping ([BankFullInfoList]) -> Void) {
        showActivity()
        
        let body = [
            "bic": bic,
            "type": ""
        ]
        
        NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList, body, [:]) { model, error in
            self.dismissActivity()
            guard let model = model else { return }
            if model.statusCode == 0 {
                
                guard let data = model.data else { return }
                completion(data.bankFullInfoList ?? [])
                
            } else {

            }
        }
    }
    
    
    func prepareExternal() {
        
        showActivity()
        
        guard let accountNumber = accountNumber.textField.text else { return }
        //TODO: сделать выборку только по картам и счетам с RUB
        //        guard let cardNumber = selectedCardNumber else {
        //            return
        //        }
        var cardId: String?
        var accountId: String?
        
        guard let bikBank = bikBankField.textField.text else { return }
        guard let comment = commentField.textField.text else { return }
        guard let inn = innField.textField.text else { return }
        guard let kpp = kppField.textField.text else { return }
        guard var nameCompany = nameCompanyField.textField.text else { return }
        
        if self.nameField.isHidden == false {
            self.fio.name = self.nameField.textField.text ?? ""
            self.fio.patronymic = self.surField.textField.text ?? ""
            self.fio.surname = self.fioField.textField.text ?? ""
            nameCompany = self.fio.surname + " " + self.fio.name + " " + self.fio.patronymic
        } else if self.innField.isHidden == true {
            guard let fio = fioField.textField.text else { return }
            nameCompany = fio
        }
        
        let unformatText = bottomView.moneyFormatter?.unformat(bottomView.amountTextField.text)
        guard let amount = unformatText?.replacingOccurrences(of: ",", with: ".") else { return }
        
        if cardField.model?.productType == "CARD" {
            cardId = "\(cardField.model?.cardID ?? 0)"
        } else {
            accountId = "\(cardField.model?.id ?? 0)"
        }
        
        var body = ["check": false,
                    "amount": amount,
                    "comment": comment,
                    "currencyAmount": "RUB",
                    "payer": ["cardId": cardId,
                              "cardNumber": nil,
                              "accountId": accountId
                             ],
                    "payeeExternal": [
                        "accountNumber": accountNumber.replacingOccurrences(of: " ", with: ""), // "40702810638110103994"
                        "date": nil,
                        "compilerStatus": nil,
                        "name": nameCompany,
                        "bankBIC": bikBank, //044525187
                        "INN": inn, //7718164343
                        "KPP": kpp
                    ]] as [String: AnyObject]
        
        if fioField.isHidden == false {
            guard fioField.textField.text != "" else {
                self.dismissActivity()
                
                return
            }
            guard nameField.textField.text != "" else {
                self.dismissActivity()
                
                return
            }
            body.removeValue(forKey: "INN")
            
            nameCompany = self.fio.surname + " " + self.fio.name + " " + self.fio.patronymic
        }
        
        guard nameCompany != "" else {
            self.dismissActivity()
            return
        }
        
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { model, error in
            self.dismissActivity()
            if error != nil {
                guard error != nil else {
                    return
                }
            } else {
                guard let model = model else {
                    return
                }
                if model.statusCode == 0 {
                    //                self.dismissActivity()
                    guard let data = model.data else {
                        return
                    }
                    //                self.selectedCardNumber = cardNumber
                    DispatchQueue.main.async {
                        self.viewModel.status = .succses
                        self.viewModel.cardFrom = self.cardField.cardModel
                        self.viewModel.summTransction = data.debitAmount?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                        self.viewModel.summInCurrency = data.creditAmount?.currencyFormatter(symbol: model.data?.currencyPayee ?? "RUB") ?? ""
                        self.viewModel.taxTransction = data.fee?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                        self.viewModel.fullName = nameCompany
                        self.viewModel.comment = comment
                        self.viewModel.cardToAccountNumber = accountNumber
                        if self.fioField.textField.text == "" {
                            self.viewModel.payToCompany = true
                        }
                        
                        let vc = ContactConfurmViewController()
                        vc.getUImage = { self.model.images.value[$0]?.uiImage }
                        vc.modalPresentationStyle = .fullScreen
                        vc.title = "Подтвердите реквизиты"
                        vc.confurmVCModel = self.viewModel
                        vc.addCloseButton()
                        vc.confurmVCModel?.template = self.viewModel.template
                        let navController = UINavigationController(rootViewController: vc)
                        navController.modalPresentationStyle = .fullScreen
                        self.present(navController, animated: true, completion: nil)
                    }
                } else {
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    
                }
            }
        }
    }
    
    func suggestCompany() {
        showActivity()
        if paymentTemplate == nil {
            nameCompanyField.textField.text = ""
            kppField.textField.text = ""
            commentField.textField.text = ""
        }
        
        let queryParameter = innField.textField.text ?? ""
        let body = [
            "query": queryParameter
        ] as [String: AnyObject]
        
        NetworkManager<SuggestCompanyDecodableModel>.addRequest(.suggestCompany, [:], body) { model, error in
            self.dismissActivity()
            DispatchQueue.main.async {
                self.nameField.isHidden = true
                self.kppField.isHidden = false
                self.commentField.isHidden = false
                self.nameCompanyField.isHidden = false
                self.stackView.addArrangedSubview(self.nameCompanyField)
                self.stackView.addArrangedSubview(self.kppField)
                self.stackView.addArrangedSubview(self.commentField)
                
            }
            guard let model = model else { return }
            
            if model.statusCode == 0 {
                guard let data = model.data else { return }
                //                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    if data.count > 1 {
                        let vc = BaseTableViewViewController()
                        vc.banks = data
                        vc.modalPresentationStyle = .automatic
                        vc.delegate = self
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    } else if data.count == 1 {
                        self.kppField.textField.text = data[0].data?.kpp
                        self.nameCompanyField.textField.text = data[0].value
                    } else {
                        self.kppField.textField.text = ""
                        self.nameCompanyField.textField.text = ""
                    }
                    
                }
            } else {
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                
            }
        }
    }
    
    func getBankList(completion: @escaping (_ banksList: [BanksList]?, _ error: String?) -> ()) {
        
        NetworkHelper.request(.getBanks) { banksList, error in
            if error != nil {
                completion(nil, error)
            }
            guard let banksList = banksList as? [BanksList] else { return }
            completion(banksList, nil)
        }
    }
    
}

extension TransferByRequisitesViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 24
        let currentString: NSString = accountNumber.textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        //            accountNumber.textField.maskString = "00000 000 0 0000 0000000"
        return newString.length <= maxLength
    }
}
