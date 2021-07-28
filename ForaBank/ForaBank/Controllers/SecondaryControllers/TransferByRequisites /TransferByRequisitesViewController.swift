//
//  TransferByRequisitesViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 30.06.2021.
//

import UIKit

struct Fio {
    var name, patronymic, surname: String
}

class TransferByRequisitesViewController: UIViewController, UITextFieldDelegate {

    var selectedBank: BanksList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }
    var banks: [BankFullInfoList]? {
        didSet {
            guard let banks = banks else { return }
//            bankListView.bankList = banks
        }
    }
    var bankListView = BankListView()

    private func setupBankField(bank: BanksList) {
        if bank.memberNameRus == "Смотреть все"{
            
        } else {
            self.bikBankField.text = bank.memberID ?? "" //"АйДиБанк"
            self.bikBankField.imageView.image = bank.svgImage?.convertSVGStringToImage() 
        }
    }
    
    var selectedCardNumber: String?
    var payerINN = "0"
    
    var bottomView = BottomInputView()
    
    var bikBankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Бик банка получателя",
            image: #imageLiteral(resourceName: "bikbank"),
            showChooseButton: true))
    
    var accountNumber = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер счета получателя",
            image: #imageLiteral(resourceName: "accountIcon")))
    
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
            title: "ИНН получателя"))
    
    var nameCompanyField = ForaInput(
        viewModel: ForaInputModel(
            title: "Наименование получателя",
            errorText: "Укажите название организации"))
    
    var kppField = ForaInput(
        viewModel: ForaInputModel(
            title: "КПП получателя",
            errorText: "Необязательное поле"))
    
    
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false
            ))
    
    var cardListView = CardListView()
    
    
    var stackView = UIStackView(arrangedSubviews: [])
    var fioStackView = UIStackView(arrangedSubviews: [])
    var fio = Fio(name: "", patronymic: "", surname: "") {
        didSet{
            if fio.name != "" && fio.patronymic != "" && fio.surname != ""{
                self.commentField.isHidden = false
                self.stackView.addSubview(commentField)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.currency = "₽"

        let item = UIBarButtonItem(image: UIImage.init(imageLiteralResourceName: "scanner"), style: .plain, target: self, action: #selector(presentScanner))
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
            if self.bikBankField.textField.text?.count == 9 {
                self.suggestBank(self.bikBankField.textField.text ?? "") { model in
                    let image = model.first?.svgImage
                    DispatchQueue.main.async {
                        self.bikBankField.imageView.image = image?.convertSVGStringToImage()
                    }
                }
            } else {
                self.bikBankField.imageView.image = UIImage(imageLiteralResourceName: "bikbank")
            }
        }
        
        bikBankField.didChooseButtonTapped = { () in
            UIView.animate(withDuration: 0.2) {
                self.openOrHideView(self.bankListView) 
            }
        }
                
        innField.didChangeValueField = {(field) in
            if self.innField.textField.text?.count == 10{
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
            if self.accountNumber.textField.text?.count == 20, self.accountNumber.textField.text?.prefix(5) == "40817" || self.accountNumber.textField.text?.prefix(5) == "40820" || self.accountNumber.textField.text?.prefix(3) == "423" || self.accountNumber.textField.text?.prefix(3) == "426" {
                self.stackView.addArrangedSubview(self.fioField)
                self.commentField.isHidden = false
                self.stackView.addArrangedSubview(self.commentField)
                self.fioField.isHidden = false
            } else if self.accountNumber.textField.text?.count == 20 {
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
        
        // Do any additional setup after loading the view.
    }
    

    
    func setupActions() {
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
        


        getBankList { [weak self]  banksList, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }

                guard let banksList = banksList else { return }
                var filteredbanksList : [BanksList] = []

                banksList.forEach { bank in
                    guard let codeList = bank.paymentSystemCodeList else { return }
//                    guard let countrylist = self?.country?.paymentSystemCodeList else { return }
//                    countrylist.forEach { code in
//                        if codeList.contains(code) {
//                            filteredbanksList.append(bank)
//                        }
//                    }
                }
//                self?.banks = banksList

//                Dict.shared.banks?.append(BanksList(memberID: "123", memberName: "Смотреть вс1е", memberNameRus: "Смотреть все", md5Hash: "", svgImage: "seeall", paymentSystemCodeList: ["123"]))
                let seeall = BanksList(memberID: "123", memberName: "Смотреть вс1е", memberNameRus: "Смотреть все", md5Hash: "", svgImage: "seeall", paymentSystemCodeList: ["123"])
//                self?.banks?.insert(seeall, at: 0)

            }
        }

        
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
//            self.openOrHideView(self.bankListView)
            self.hideView(self.bankListView, needHide: true)
            self.hideView(self.cardListView, needHide: true)
        }
        
        bankListView.didSeeAll = { (bank) in
            self.selectedBank = bank
            let vc = SearchBanksViewController()
//            vc.banks = self.banks!
            let navController = UINavigationController(rootViewController: vc)
//            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
        
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
            self.hideView(self.bankListView, needHide: true)
        }
        
        
        cardListView.didCardTapped = { card in
            self.cardField.configCardView(card)
            self.selectedCardNumber = card.number ?? ""
            self.hideView(self.cardListView, needHide: true)
            self.hideView(self.bankListView, needHide: true)
            
        }
        
        bottomView.didDoneButtonTapped = { [weak self] (_) in
            self?.doneButtonTapped()
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
        cardListView.didCardTapped = {[weak self] (card) in
            print(card)
        }
        cardField.didChooseButtonTapped = { () in
            UIView.animate(withDuration: 0.2, animations: {
                self.cardListView.isHidden.toggle()
            })
        }

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
//            self.banks = model

        }
    }
    
    func updateUI(){
        
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
            "bic": bic
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
        guard let bikBank = bikBankField.textField.text else {
            return
        }
        guard let comment = commentField.textField.text else {
            return
        }
        guard var inn = innField.textField.text else {
            return
        }
        guard let kpp = kppField.textField.text else {
            return
        }
        
        guard var nameCompany = nameCompanyField.textField.text else {
            return
        }
        
        if fioField.textField.text?.count != 0{
            guard let fio = fioField.textField.text else {
                    return
            }
            inn = "0"
            nameCompany = fio
        }
        
        let body = [
            "payerCardNumber": "4656260150230695",
            "amount": 100,
            "comment": "\(comment)",
            "date": "2020-01-27",
            "payeeAccountNumber": "40702810638110103994",
            "payeeBankBIC": "\(bikBank)",
            "payeeINN": "\(inn)",
            "payeeKPP": "\(kpp)",
            "payeeName": "\(nameCompany)"
        ] as [String: AnyObject]
        
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer , [:], body) { model, error in
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()
                guard let data  = model.data else { return }
//                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    let vc = TransferByRequisitesConfirmViewController()
                    vc.addCloseButton()
                    if self.fioField.textField.text == ""{
                        vc.byCompany = true
                        vc.fioField.text = "Наименование получателя"
                        vc.fioField.text = self.nameCompanyField.textField.text ?? ""
                        vc.commentField.text = self.commentField.textField.text ?? ""
                        vc.accountNumber.text = self.accountNumber.textField.text ?? ""
                        vc.summTransctionField.text = self.bottomView.amountTextField.text ?? "" + "₽"

                    } else{
                        vc.accountNumber.text = self.accountNumber.textField.text ?? ""
                        vc.fioField.text = "\(self.fio.name )" + " " + "\(self.fio.patronymic)" + " " + "\(self.fio.surname)"
                        vc.commentField.text = self.commentField.textField.text ?? ""
                        vc.summTransctionField.text = self.bottomView.amountTextField.text ?? ""
                    }
//                    if data.fee {
//                    if data.commission?.count != 0 {
                    vc.taxTransctionField.text = data.fee?.currencyFormatter(symbol: "RUB") ?? "" // "\(data.commission?[0].amount ?? 0) ₽"
//                    } else {
//                        vc.taxTransctionField.isHidden = true
//                    }
                    

                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                    
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
        NetworkManager<PrepareExternalDecodableModel>.addRequest(.prepareExternal , [:], body) { model, error in
//            if error != nil {
//                self.dismissActivity()
//                print("DEBUG: Error: ", error ?? "")
//            }
            
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
                self.dismissActivity()
                guard let data  = model.data else { return }
//                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    if data.count > 0 {
                        self.kppField.textField.text = data[0].data?.kpp
                        self.nameCompanyField.textField.text = data[0].value
                    }
                    
                }
            } else {
                self.dismissActivity()
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
