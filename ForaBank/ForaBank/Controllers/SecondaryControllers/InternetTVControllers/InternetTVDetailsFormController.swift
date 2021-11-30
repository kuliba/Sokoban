import UIKit
import RealmSwift

class InternetTVDetailsFormController: BottomPopUpViewAdapter, UITableViewDataSource, InternetTableViewDelegate, IMsg {
    static var iMsg: IMsg? = nil
    static let msgIsSingleService = 1

    var bodyValue = [String : String]()
    var bodyArray = [[String : String]]()
    var operatorData: GKHOperatorsModel?
    var valueToPass : String?
    var puref = ""
    var cardNumber = ""
    var product: GetProductListDatum?
    var qrData = [String: String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    @IBOutlet weak var goButton: UIButton!

    lazy var realm = try? Realm()
    var cardList: Results<UserAllCardsModel>? = nil
    let footerView = GKHInputFooterView()


    func handleMsg(what: Int) {
        switch (what) {
        case InternetTVDetailsFormController.msgIsSingleService:
            if !InternetTVApiRequests.isSingleService {
                let alertController = UIAlertController(title: "Внимание!", message: "Временно нельзя провести оплату по этому поставщику", preferredStyle: UIAlertController.Style.alert)

                let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
                    self.dismiss(animated: true)
                })
                alertController.addAction(saveAction)
                present(alertController, animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        InternetTVDetailsFormController.iMsg = self
        cardList = realm?.objects(UserAllCardsModel.self)
        
        if !qrData.isEmpty {
            let a = qrData.filter { $0.key == "Sum"}
            bottomInputView.tempTextFieldValue = a.first?.value ?? ""
        }
        
        bottomInputView?.isHidden = true
        setupNavBar()
//        goButton.isEnabled = false
//        goButton.backgroundColor = .lightGray
        goButton.add_CornerRadius(5)
        puref = operatorData?.puref ?? ""
        InternetTVApiRequests.isSingleService(puref: puref)
        tableView.register(UINib(nibName: "InternetInputCell", bundle: nil), forCellReuseIdentifier: InternetTVInputCell.reuseId)
//        tableView.register(GKHInputFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionFooter")
        
        // Изменения символа валюты
        bottomInputView.currencySymbol = "₽"
        /// Загружаем карты
        AddAllUserCardtList.add {
            
        }
        // Замыкание которое срабатывает по нажатию на кнопку продолжить
        // amount значение выдает отформатированное значение для передачи в запрос
        bottomInputView.didDoneButtonTapped = { amount in
            self.showActivity()
            
            // Запрос на платеж в ЖКХ : нужно добавить параметры в рапрос
            self.paymentGKH(amount: amount) { model, error in
                self.dismissActivity()
                
                if error != nil {
                    print("DEBUG: Error: endContactPayment ", error ?? "")
                    self.showAlert(with: "Ошибка", and: error!)
                } else {
                    guard let model = model else { return }
                    // Переход на экран подтверждения
                    self.goToConfirmVC(with: model)
                }
                // Функция настройки выбранной карты и список карт
                self.setupCardList { error in
                    guard let error = error else { return }
                    self.showAlert(with: "Ошибка", and: error)
                }
            }
        }
        
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height + 70
            tableView.tableFooterView = footerView
            tableView.layoutIfNeeded()
        }
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        goButton.isHidden = true
        bottomInputView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        qrData.removeAll()
    }

    func setupNavBar() {

        let operatorsName = operatorData?.name ?? ""
        let inn = operatorData?.synonymList.first ?? ""
        self.navigationItem.titleView = set_Title(title: operatorsName, subtitle: "ИНН " +  inn )

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit

        if operatorData?.logotypeList.first?.content != nil {

//            UserDefaults.standard.set(operatorData?.logotypeList.first?.content ?? "", forKey: "OPERATOR_IMAGE")

            let dataDecoded : Data = Data(base64Encoded: operatorData?.logotypeList.first?.content ?? "", options: .ignoreUnknownCharacters)!

            let decodedimage = UIImage(data: dataDecoded)
            imageView.image = decodedimage
            imageView.setDimensions(height: 30, width: 30)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)

        } else {
            imageView.image = UIImage(named: "GKH")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

    }

    func set_Title(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width),  height: 30))
        titleView.setDimensions(height: 30, width: 300)
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        titleLabel.numberOfLines = 3;

        titleLabel.anchor( left: titleView.leftAnchor, right: titleView.rightAnchor)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleView.leftAnchor, right: titleView.rightAnchor)
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

    //MARK: - Helpers
    func goToConfirmVC(with model: ConfirmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.title = "Подтвердите реквизиты"
            vc.confurmVCModel = model
            vc.countryField.isHidden = true
            vc.phoneField.isHidden = true
            vc.nameField.isHidden = true
            vc.bankField.isHidden = true
            vc.numberTransctionField.isHidden = true
            vc.cardToField.isHidden = true
            vc.summTransctionField.isHidden = false
            vc.taxTransctionField.isHidden = false
            vc.currTransctionField.isHidden = true
            vc.currancyTransctionField.isHidden = true
            vc.operatorView = self.operatorData?.logotypeList.first?.content ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupCardList(completion: @escaping ( _ error: String?) ->() ) {
        
//        self.cardList?.forEach{ card in
//            if (card.allowDebit && card.productType == "CARD") {
//                var filterProduct: [UserAllCardsModel] = []
//                filterProduct.append(card)
//                self.footerView.cardListView.cardList = filterProduct
//                self.footerView.cardFromField.cardModel = filterProduct.first
//                self.cardNumber  = filterProduct.first?.accountNumber ?? ""
//            }
//        }
        
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async { [self] in
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                var arrProducts: [GetProductListDatum] = []
                data.forEach { product in
                    if (product.productType == "CARD" || product.productType == "ACCOUNT") && product.currency == "RUB" {
                        if product.allowDebit == true {
                        arrProducts.append(product)
                        }
                    }
                }
                
                self?.footerView.cardListView.cardList = arrProducts
                self?.footerView.cardFromField.cardModel = arrProducts.first

                //self?.product = arrProducts.first
                self?.cardNumber  = arrProducts.first?.number ?? ""
//                                self?.cardListView.cardList = filterProduct
//
//                                if filterProduct.count > 0 {
//                                    self?.cardFromField.cardModel = filterProduct.first
//                                    guard let cardNumber  = filterProduct.first?.number else { return }
//                                    self?.selectedCardNumber = cardNumber
//                                    self?.cardIsSelect = true
//                                    completion(nil)
//                                }
            }
        }
    }


    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
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
    }

    func load() {
        var latestOperations = [InternetTVLatestOperationsModel]()

        NetworkManager<GetLatestServicePaymentsDecodableModel>.addRequest(.getLatestInternetTVPayments, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let additionalListData = model.data else { return }

                additionalListData.forEach { list in
                    let ob = InternetTVLatestOperationsModel()
                    ob.amount    = list.amount ?? 0
                    ob.paymentDate = list.paymentDate
                    ob.puref    = list.puref

                    list.additionalList?.forEach({ parameterList in
                        let param = AdditionalListModel()
                        param.fieldName       = parameterList.fieldName
                        param.fieldValue     = parameterList.fieldValue
                        ob.additionalList.append(param)
                    })

                    latestOperations.append(ob)
                }

                let realm = try? Realm()
                do {
                    let operators = realm?.objects(InternetTVLatestOperationsModel.self)
                    realm?.beginWrite()
                    realm?.delete(operators!)
                    realm?.add(latestOperations)
                    try realm?.commitWrite()
                    print("REALM",realm?.configuration.fileURL?.absoluteString ?? "")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func paymentGKH(amount: String ,completion: @escaping (_ model: ConfirmViewControllerModel? ,_ error: String?) -> ()) {
        var body = [String: AnyObject]()
        if footerView.cardFromField.cardModel?.productType == "ACCOUNT" {
            let id = footerView.cardFromField.cardModel?.id ?? -1
            body = [ "check" : false,
                     "amount" : amount,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : nil,
                                 "cardNumber" : nil,
                                 "accountId" : id ],
                     "puref" : puref,
                     "additional" : bodyArray] as [String: AnyObject]

        } else if footerView.cardFromField.cardModel?.productType ==  "CARD" {
            let id = footerView.cardFromField.cardModel?.id ?? -1
            body = [ "check" : false,
                     "amount" : amount,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : id,
                                 "cardNumber" : nil,
                                 "accountId" : nil ],
                     "puref" : puref,
                     "additional" : bodyArray] as [String: AnyObject]
        }

        print("DEBUG: GKHInputView" , body)
        
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createInternetTransfer, [:], body) { respModel, error in
            if error != nil {
                print("DEBUG: Error: ContaktPaymentBegin ", error ?? "")
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let data = respModel.data else { return }
                let model = ConfirmViewControllerModel(type: .gkh)
                let r = Double(data.debitAmount ?? 0)
                model.summTransction = r.currencyFormatter(symbol: "RUB")
                let c = Double(data.fee ?? 0)
                model.taxTransction = c.currencyFormatter(symbol: "RUB")
                completion(model, nil)
            } else {
                print("DEBUG: Error: ContaktPaymentBegin ", respModel.errorMessage ?? "")
                completion(nil, respModel.errorMessage)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operatorData?.parameterList.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InternetTVInputCell.reuseId, for: indexPath) as! InternetTVInputCell
        guard operatorData?.parameterList.count != 0 else { return cell }

        cell.setupUI(indexPath.row, (operatorData?.parameterList[indexPath.row])!, qrData)
        cell.tableViewDelegate = (self as InternetTableViewDelegate)

        cell.showInfoView = { value in
            let infoView = GKHInfoView()
            infoView.lable.text = value
            self.showAlert(infoView)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let hight: CGFloat = 80.0
        return hight
    }

    func afterClickingReturnInTextField(cell: InternetTVInputCell) { //GKHInputCell
        bodyValue.removeAll()
        bodyValue = cell.body
        bodyArray.append(bodyValue)
    }
}

@objc protocol InternetTableViewDelegate: NSObjectProtocol{
    func afterClickingReturnInTextField(cell: InternetTVInputCell)
}

class InternetTVInputCell: UITableViewCell, UITextFieldDelegate {

    var info = ""

    var showInfoView: ((String) -> ())? = nil
    var showGoButton: ((Bool) -> ())? = nil

    weak var tableViewDelegate: InternetTableViewDelegate?

    static let reuseId = "InternetTVInputCell"

    var fieldid = ""
    var fieldname = ""
    var fieldvalue = ""
    var body = [String: String]()
    var perAcc = ""
    var isSelect = true
    @IBOutlet weak var infoButon: UIButton!
    @IBOutlet weak var operatorsIcon: UIImageView!
    @IBOutlet weak var showFioButton: UIButton!
    @IBOutlet weak var placeholderLable: UILabel!
    @IBOutlet weak var errorLable: UILabel!
    @IBOutlet weak var showFIOButton: UIButton!
    @IBOutlet weak var payTypeButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!

    var placeholder = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
    }

    // UITextField Defaults delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        fieldvalue = textField.text ?? ""
    }
    // DataSetup
//    func setupUI (_ index: Int, _ dataModel: [String: String]) {
//        if emptyCell() == false {
//            infoButon.isHidden = true
//            self.fieldid = String(index + 1)
//            fieldname = dataModel["id"] ?? ""
//            let q = GKHDataSorted.a(dataModel["title"] ?? "")
//
//            DispatchQueue.main.async {
//                self.operatorsIcon.image = UIImage(named: q.1)
//            }
//
//            textField.placeholder = q.0
//            placeholder = q.0
//
//            if q.0 == "Лицевой счет" {
//                let h = dataModel["Лицевой счет"]
//                perAcc = h ?? ""
//                if h != "" {
//                    textField.text = h
//                }
//            }
//
//            if q.0 == "" {
//                textField.placeholder = dataModel["title"] ?? ""
//            }
//            if q.0 == "ФИО" {
//                showFioButton.isHidden = false
//            } else {
//                showFioButton.isHidden = true
//            }
//
//            if dataModel["subTitle"] != nil {
//                info = dataModel["subTitle"] ?? ""
//                infoButon.isHidden = false
//            }
//            if dataModel["viewType"] != "INPUT" {
//                self.textField.isEnabled = false
//                isSelect = false
//            }
//        }
//    }

    func setupUI (_ index: Int, _ dataModel: Parameters, _ qrData: [String: String]) {

        infoButon.isHidden = true
        self.fieldid = String(index + 1)
        fieldname = dataModel.id ?? ""
        let q = GKHDataSorted.a(dataModel.title ?? "")

        DispatchQueue.main.async {
            self.operatorsIcon.image = UIImage(named: q.1)
        }

        textField.placeholder = q.0
        placeholder = q.0

        if q.0 == "Лицевой счет" {
            let h = qrData.filter { $0.key == "Лицевой счет"}
            if h.first?.value != "" {
                textField.text = h.values.first
            }
        }

        if q.0 == "" {
            textField.placeholder = dataModel.title
        }
        if q.0 == "ФИО" {
            showFioButton.isHidden = false
        } else {
            showFioButton.isHidden = true
        }

        if dataModel.subTitle != nil {
            info = dataModel.subTitle ?? ""
            infoButon.isHidden = false
        }
    }

    @IBAction func textField(_ sender: UITextField) {
        fieldvalue = textField.text ?? ""
        body.updateValue(fieldid, forKey: "fieldid")
        body.updateValue(fieldname, forKey: "fieldname")
        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        self.perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()
        tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //        let previousText:NSString = textField.text! as NSString
        //        let updatedText = previousText.replacingCharacters(in: range, with: string)
        //        print("updatedText > ", updatedText)
        return true
    }

    @IBAction func payTapButton(_ sender: UIButton) {
    }

    @IBAction func showFIOButton(_ sender: UIButton) {
    }

    @IBAction func showInfo(_ sender: UIButton) {
        showInfoView?(info)
    }

    final func haveEmptyCell() {

        if ( fieldvalue != "" && isSelect == true) {
            showGoButton?(true)
        } else if ( fieldvalue == "" && isSelect == false) {
            showGoButton?(true)
        }
        if ( fieldvalue == "" && isSelect == true) {
            showGoButton?(false)
        }
    }

    final func emptyCell() -> Bool {

        var result = false
        if ( fieldid != "" || fieldname != "" || fieldvalue != "" ) {
            result = true
        }
        return result
    }

}

import Foundation
import RealmSwift


struct InternetTVApiRequests {
    static var isSingleService = true

    static func isSingleService(puref: String) {
        let body = ["puref" : puref] as [String: AnyObject]
        NetworkManager<IsSingleServiceModel>.addRequest(.isSingleService, [:], body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let data = model.data else { return }
                isSingleService = data
                InternetTVDetailsFormController.iMsg?.handleMsg(what: InternetTVDetailsFormController.msgIsSingleService)
            }
        }
    }

    struct IsSingleServiceModel: Codable, NetworkModelProtocol {
        let statusCode: Int?
        let errorMessage: String?
        let data: Bool?

        init(data: Data) throws {
            self = try newJSONDecoder().decode(IsSingleServiceModel.self, from: data)
        }
    }

}

