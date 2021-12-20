//
//  TransferByRequisitesViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 30.06.2021.
//

import UIKit
import RealmSwift

struct Fio {
    var name, patronymic, surname: String
}

class TransferByRequisitesViewController: UIViewController, UITextFieldDelegate, MyProtocol {

    lazy var realm = try? Realm()
    var cardIsSelect = false

    
    var viewModel = ConfirmViewControllerModel(type: .requisites) {
        didSet {
//            checkModel(with: viewModel)
        }
    }
    
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
    var bankListView = FullBankInfoListView()

    private func setupBankField(bank: BankFullInfoList) {
        self.bikBankField.text = bank.bic ?? "" //"АйДиБанк"
        
        if let imageString = bank.svgImage {
            self.bikBankField.imageView.image =  imageString.convertSVGStringToImage()
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
    
    var cardListView = CardsScrollView(onlyMy: true)

    
    
    var stackView = UIStackView(arrangedSubviews: [])
    var fioStackView = UIStackView(arrangedSubviews: [])
    var fio = Fio(name: "", patronymic: "", surname: "") {
        didSet{
            if fio.name != "" && fio.patronymic != "" && fio.surname != ""{
//                self.commentField.isHidden = false
//                self.stackView.addSubview(commentField)
            }
        }
    }

    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func presentScanner(){
        let vc = QRScannerViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    var delegate: MyProtocol?
    @objc func myTargetFunction(textField: UITextField) {
        if self.nameField.isHidden ==    true {
            self.fioField.placeHolder.text = "Фамилия"
            self.nameField.isHidden = false
            self.surField.isHidden = false
            self.stackView.insertArrangedSubview(self.nameField, at: 6)
            self.stackView.insertArrangedSubview(self.surField, at: 7)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AddAllUserCardtList.add() {
           print(" AddAllUserCardtList.add()")
        }
        bottomView.currencySymbol = "₽"

        let item = UIBarButtonItem(image: UIImage.init(imageLiteralResourceName: "scanner"), style: .plain, target: self, action: #selector(presentScanner))
        item.tintColor = .lightGray
        item.isEnabled = false
        self.navigationItem.setRightBarButton(item, animated: false)
//        navigationItem.rightBarButtonItem?.action = #selector(doneButtonTapped)
        nameCompanyField.errorLabel.sizeToFit()
        kppField.errorLabel.sizeToFit()
        nameCompanyField.errorLabel.isHidden = false
        nameCompanyField.errorLabel.alpha = 1
        nameCompanyField.errorLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        kppField.errorLabel.isHidden = false
        kppField.errorLabel.alpha = 1
        kppField.errorLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)

        commentField.errorLabel.alpha = 1
        commentField.errorLabel.isHidden = false
        commentField.errorLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        innField.errorLabel.isHidden = true
        innField.errorLabel.alpha = 0

        DispatchQueue.main.async {
            var filterProduct: [UserAllCardsModel] = []
            let cards = ReturnAllCardList.cards()
            cards.forEach { product in
                if (product.productType == "CARD"
                        || product.productType == "ACCOUNT") && product.currency == "RUB" {
                    filterProduct.append(product)
                }
            }
//            self.cardListView.cardList = filterProduct
            if filterProduct.count > 0 {
                self.cardField.model = filterProduct.first
                guard let cardNumber  = filterProduct.first?.number else { return }
                self.selectedCardNumber = cardNumber
                self.cardIsSelect = true
            }
        }
        
//        commentField.errorLabel.text = "Укажите дополнительную информацию"
//        commentField.errorLabel.isHidden = false
////        commentField.errorLabel.textColor =
//        kppField.errorLabel.isHidden = false
//        kppField.errorLabel.text = "Необязательное поле"
//        nameField.errorLabel.isHidden = false
//        nameField.errorLabel.text = "Укажите название организации"
        
        
        fioField.chooseButton.setImage(UIImage(imageLiteralResourceName: "extensionButton"), for: .normal)
        
        bottomView.didDoneButtonTapped = {(amount) in
            self.prepareExternal()
        }
        

        bikBankField.didChangeValueField = {(field) in
            self.hideView(self.bankListView, needHide: false)
            self.bankListView.textFieldDidChanchedValue(textField: field)
//            if self.bikBankField.textField.text?.count == 9 {
//                self.suggestBank(self.bikBankField.textField.text ?? "") { model in
//                    let image = model.first?.svgImage
//                    DispatchQueue.main.async {
//                        self.bikBankField.imageView.image = image?.convertSVGStringToImage()
//                    }
//                }
//            } else {
//                self.bikBankField.imageView.image = UIImage(imageLiteralResourceName: "bikbank")
//            }
        }
        
        bikBankField.didChooseButtonTapped = { () in
            UIView.animate(withDuration: 0.2) {
                self.openOrHideView(self.bankListView) 
            }
        }
                
        innField.didChangeValueField = {(field) in
            if self.innField.textField.text?.count == 10 || self.innField.textField.text?.count == 12{
                self.suggestCompany()
            } else {
                    self.nameField.isHidden = true
                    self.kppField.isHidden = true
                    self.nameCompanyField.isHidden = true
                    self.commentField.isHidden = true
            }
        }
//        nameField.didChangeValueField = {(field) in
//            self.nameField.errorLabel.isHidden = false
//            self.nameField.errorLabel.text = "Укажите название организации"
//        }
        fioField.textField.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
            
       
            self.fioField.didChooseButtonTapped = { () in
            self.fioField.placeHolder.text = "Фамилия"
            self.nameField.isHidden.toggle()
            self.surField.isHidden.toggle()
            self.stackView.insertArrangedSubview(self.nameField, at: 6)
            self.stackView.insertArrangedSubview(self.surField, at: 7)
                if self.fioField.textField.text?.count != 0{
                    self.fioField.textField.text = self.fio.surname
                } else {
                    self.fioField.textField.text = self.fio.surname
                }
                
            if self.nameField.isHidden || self.nameField.textField.text == ""   {
                self.fio.name = self.nameField.textField.text ?? ""
                self.fio.patronymic = self.surField.textField.text ?? ""
                self.fio.surname = self.fioField.textField.text ?? ""
                self.fioField.textField.text = self.fio.surname + " " +  self.fio.name + " " + self.fio.patronymic
            }
                
//            self.fioField.textField.text = "\(fioField.textField.text  nameField.textField.text surField.textField.text)"
         }
        surField.didChangeValueField = {(field) in
            
        }
        fioField.didChangeValueField = {(field) in
            if self.nameField.isHidden == true {
                self.fioField.textField.text = self.fio.surname + self.fio.patronymic + self.fio.name
            } else {
                self.fio.surname = self.fioField.textField.text ?? ""
            }


        }
        
        accountNumber.didChangeValueField = {(field) in
            self.accountNumber.textField.maskString = "00000 000 0 0000 0000000"
            if self.accountNumber.textField.text?.replacingOccurrences(of: " ", with: "").count == 20, self.accountNumber.textField.text?.prefix(5) == "40817" || self.accountNumber.textField.text?.prefix(5) == "40820" || self.accountNumber.textField.text?.prefix(3) == "423" || self.accountNumber.textField.text?.prefix(3) == "426" {
                self.stackView.addArrangedSubview(self.fioField)
//                self.commentField.isHidden = false
//                self.stackView.addArrangedSubview(self.commentField)
                self.fioField.isHidden = false
            } else if self.accountNumber.textField.text?.replacingOccurrences(of: " ", with: "").count == 20 {
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
        
 
        setupUI()
        setupActions()
        
//        setupCardList()
        
        // Do any additional setup after loading the view.
    }
    

    func sendData(kpp: String, name: String) {
        self.kppField.text = kpp
        self.nameCompanyField.textField.text = name
       }

    
    func setupActions() {
//        getCardList { [weak self] data ,error in
//            DispatchQueue.main.async {
//
//                if error != nil {
//                    self?.showAlert(with: "Ошибка", and: error!)
//                }
//                guard let data = data else { return }
//                self?.cardListView.cardList = data
//
//                if data.count > 0 {
//                    self?.cardField.configCardView(data.first!)
//                    guard let cardNumber  = data.first?.number else { return }
//                    self?.selectedCardNumber = cardNumber
//                }
//            }
//        }
    
        
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
//            self.openOrHideView(self.bankListView)
            self.hideView(self.bankListView, needHide: true)
            self.hideView(self.cardListView, needHide: true)
        }
        
//        bankListView.didSeeAll = { () in
////            self.selectedBank = bank
//            let vc = SearchBanksViewController()
//            vc.banks = self.banks
//            let navController = UINavigationController(rootViewController: vc)
////            navController.modalPresentationStyle = .fullScreen
//            self.present(navController, animated: true, completion: nil)
//        }
        
        
        bankListView.didBankTapped = { (bank) in self.selectBank(bank: bank)}
        
        bankListView.didSeeAll = { () in self.openSearchBanksVC() }
        
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
            self.hideView(self.bankListView, needHide: true)
        }
        
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {

                
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
                cardList.forEach({ card in
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
        
        bottomView.didDoneButtonTapped = { [weak self] (_) in
//            fatalError()
            self?.doneButtonTapped()
        }
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
    
    func setupUI() {
        
        addCloseButton()
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(bottomView)
        
        self.navigationItem.titleView = setTitle(title: "Перевести", subtitle: "Человеку или организации")

        
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
        suggestBank("") { model in
            self.banks = model

        }
    }
    
    func setuoUIByCompany(){
        stackView.addArrangedSubview(innField)
    }
    
    func setupConstraint() {
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 20)
        
    }
    
    @objc func doneButtonTapped() {
        prepareExternal()
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
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

    
    func suggestBank(_ bic: String, completion: @escaping ([BankFullInfoList]) -> Void ) {
        showActivity()
        
        let body = [
            "bic": bic,
            "type": ""
        ]
        
        NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList , body, [:]) { model, error in
//            if error != nil {
//                self.dismissActivity()
//                print("DEBUG: Error: ", error ?? "")
//            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()
                guard let data  = model.data else { return }
//                self.selectedCardNumber = cardNumber
//                let image = data.bankFullInfoList?.first?.svgImage
                completion(data.bankFullInfoList ?? [])
                
//                DispatchQueue.main.async {
//                    self.bikBankField.imageView.image = self.convertSVGStringToImage(image ?? "")
//                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
    
    func prepareExternal(){
        
        showActivity()

        guard let accountNumber = accountNumber.textField.text else {
            return
        }
        //TODO: сделать выборку только по картам и счетам с RUB
//        guard let cardNumber = selectedCardNumber else {
//            return
//        }
        var cardId: String?
        var accountId: String?
        
        guard let bikBank = bikBankField.textField.text else {
            return
        }
        guard let comment = commentField.textField.text else {
            return
        }
        guard let inn = innField.textField.text else {
            return
        }
        guard let kpp = kppField.textField.text else {
            return
        }
        
        guard var nameCompany = nameCompanyField.textField.text else {
            return
        }
        if self.nameField.isHidden == false {
            self.fio.name = self.nameField.textField.text ?? ""
            self.fio.patronymic = self.surField.textField.text ?? ""
            self.fio.surname = self.fioField.textField.text ?? ""
            nameCompany = self.fio.surname + " " +  self.fio.name + " " + self.fio.patronymic
        } else if self.innField.isHidden == true {
            guard let fio = fioField.textField.text else {
                    return
            }
            nameCompany = fio
        }
        
        let unformatText = bottomView.moneyFormatter?.unformat(bottomView.amountTextField.text)
        guard let amount = unformatText?.replacingOccurrences(of: ",", with: ".") else { return }
        
        if cardField.model?.productType == "CARD"{
            cardId = "\(cardField.model?.cardID ?? 0)"
        } else {
            accountId = "\(cardField.model?.id ?? 0)"
        }
    
        var body = [ "check" : false,
                     "amount" : amount,
                     "comment" : comment,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : cardId,
                                 "cardNumber" : nil,
                                 "accountId" : accountId
                               ],
                     "payeeExternal" : [
                        "accountNumber" : accountNumber.replacingOccurrences(of: " ", with: ""), // "40702810638110103994"
                        "date" : nil,
                        "compilerStatus": nil,
                        "name" : nameCompany,
                        "bankBIC" : bikBank, //044525187
                        "INN" : inn, //7718164343
                        "KPP" : kpp
                     ] ] as [String : AnyObject]
        if fioField.textField.text?.count != 0{
            guard fioField.textField.text != nil else {
                    return
            }
            body.removeValue(forKey: "INN")
            
            nameCompany = self.fio.surname + " " +  self.fio.name + " " + self.fio.patronymic
//            body["name"] = fio as AnyObject
        }
        
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer , [:], body) { model, error in
            self.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                print("DEBUG: Error: ", error)
            } else {
                guard let model = model else { return }
                print("DEBUG: Card list: ", model)
                if model.statusCode == 0 {
    //                self.dismissActivity()
                    guard let data  = model.data else { return }
    //                self.selectedCardNumber = cardNumber
                    DispatchQueue.main.async {
                        self.viewModel.statusIsSuccses = true
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
                        vc.modalPresentationStyle = .fullScreen
                        vc.title = "Подтвердите реквизиты"
                        vc.confurmVCModel = self.viewModel
                        
                        
                        self.navigationController?.pushViewController(vc, animated: true)
//                        let vc = TransferByRequisitesConfirmViewController()
//                        vc.addCloseButton()
//                        if self.fioField.textField.text == ""{
//                            vc.byCompany = true
//                            vc.fioField.text = "Наименование получателя"
//                            vc.fioField.text = self.nameCompanyField.textField.text ?? ""
//                            vc.commentField.text = self.commentField.textField.text ?? ""
//                            vc.accountNumber.text = self.accountNumber.textField.text ?? ""
//                            vc.summTransctionField.text = self.bottomView.amountTextField.text ?? "" + "₽"
//
//                        } else{
//                            vc.accountNumber.text = self.accountNumber.textField.text ?? ""
//                            vc.fioField.text = "\(self.fio.name )" + " " + "\(self.fio.patronymic)" + " " + "\(self.fio.surname)"
//                            vc.commentField.text = self.commentField.textField.text ?? ""
//                            vc.summTransctionField.text = self.bottomView.amountTextField.text ?? ""
//                        }
//                        vc.taxTransctionField.text = data.fee?.currencyFormatter(symbol: "RUB") ?? ""
                        

//                        let navController = UINavigationController(rootViewController: vc)
//                        navController.modalPresentationStyle = .fullScreen
//                        self.present(navController, animated: true, completion: nil)
                        
                    }
                } else {
    //                self.dismissActivity()
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                        self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

//                    }
                }
                
            }
            
        }

    }
    
    func suggestCompany(){
        showActivity()
        nameCompanyField.textField.text = ""
        kppField.textField.text = ""
        commentField.textField.text = ""
        let body = [
            "query": innField.textField.text
        ] as [String: AnyObject]
        
        NetworkManager<SuggestCompanyDecodableModel>.addRequest(.suggestCompany , [:], body) { model, error in
//            if error != nil {
//                self.dismissActivity()
//                print("DEBUG: Error: ", error ?? "")
//            }
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
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
//                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    if data.count > 1 {
                        let vc = BaseTableViewViewController()
                        vc.banks = data
                        vc.modalPresentationStyle = .automatic
                        vc.delegate = self
                        self.navigationController?.pushViewController(vc, animated: true)

                    } else if data.count == 1{
                        self.kppField.textField.text = data[0].data?.kpp
                        self.nameCompanyField.textField.text = data[0].value
                    } else {
                        self.kppField.textField.text = ""
                        self.nameCompanyField.textField.text = ""
                    }
                    
                }
            } else {
                self.dismissActivity()

                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        
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
        
        
//        NetworkHelper.request(.getProductList) { cardList , error in
//            if error != nil {
//                completion(nil, error)
//            }
//            guard let cardList = cardList as? [GetProductListDatum] else { return }
//            completion(cardList, nil)
//            print("DEBUG: Load card list... Count is: ", cardList.count)
//        }
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
    
}

extension TransferByRequisitesViewController{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let maxLength = 24
            let currentString: NSString = accountNumber.textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
//            accountNumber.textField.maskString = "00000 000 0 0000 0000000"
            return newString.length <= maxLength
    }
}
