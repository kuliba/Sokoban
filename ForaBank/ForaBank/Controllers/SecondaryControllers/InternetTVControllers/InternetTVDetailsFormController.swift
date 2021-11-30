import UIKit
import RealmSwift
import Foundation


class InternetTVDetailsFormController: BottomPopUpViewAdapter, UITableViewDataSource, InternetTableViewDelegate, IMsg {
    static var iMsg: IMsg? = nil
    static let msgIsSingleService = 1

    var bodyValue = [String : String]()
    var additionalElement = [String : String]()
    var additionalDic = [String : [String : String]]()
    var operatorData: GKHOperatorsModel?
    var requisites = [Requisite]()
    var valueToPass : String?
    var puref = ""
    var cardNumber = ""
    var product: GetProductListDatum?
    var qrData = [String: String]()
    var firstStep = true
    var firstAdditional = [[String: String]]()
    var stepsPayment = [[[String: String]]]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    @IBOutlet weak var goButton: UIButton!

    lazy var realm = try? Realm()
    var cardList: Results<UserAllCardsModel>? = nil
    let footerView = GKHInputFooterView()


    func handleMsg(what: Int) {
        switch (what) {
        case InternetTVDetailsFormController.msgIsSingleService:
//            if !InternetTVApiRequests.isSingleService {
//                let alertController = UIAlertController(title: "Внимание!", message: "Временно нельзя провести оплату по этому поставщику", preferredStyle: UIAlertController.Style.alert)
//
//                let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
//                    self.dismiss(animated: true)
//                })
//                alertController.addAction(saveAction)
//                present(alertController, animated: true, completion: nil)
//            }
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
        bottomInputView.currencySymbol = "₽"
        AddAllUserCardtList.add {}

        bottomInputView.didDoneButtonTapped = { amount in
            self.showActivity()
            if InternetTVApiRequests.isSingleService {
                self.requestCreateInternetTransfer(amount: amount)
            } else {
                if !self.firstStep {
                    self.retryPayment(amount: amount)
                    //self.requestNextCreateInternetTransfer(amount: amount)
                }
            }
        }
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }

        if let list = operatorData?.parameterList {
            list.forEach { item in
                let req = Requisite.convertParameter(item)
                requisites.append(req)
            }
            tableView.reloadData()
        }
    }

    func retryPayment(amount: String) {
        let request = getCreateRequest(amount: amount, additionalArray: firstAdditional)
        doCreateInternetTransfer(request: request) {  response, error in
            self.dismissActivity()
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if let respUnw = response {
                    if respUnw.data?.finalStep ?? false {
                        self.doConfirmation(response: respUnw)
                    } else {
                        self.showActivity()
                        self.continueRetry(amount: amount)
                    }
                }
            }
        }
    }

    func continueRetry(amount: String) {
        var additionalArray = [[String: String]]()
        additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        var request = getNextStepRequest(amount: amount, additionalArray: additionalArray)
        if stepsPayment.count > 0 {
            request = getNextStepRequest(amount: amount, additionalArray: stepsPayment.removeFirst())
        }
        doNextStepServiceTransfer(request: request) { response, error in
            self.dismissActivity()
            self.animationShow(self.goButton)
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if let respUnw = response {
                    if respUnw.data?.finalStep ?? false {
                        self.doConfirmation(response: respUnw)
                    } else {
                        self.continueRetry(amount: amount)
                    }
                }
            }
        }
    }

    func showFinalStep() {
        animationHidden(goButton)
        animationShow(bottomInputView)
    }

    func requestCreateInternetTransfer(amount: String) {
        showActivity()
        var additionalArray = [[String: String]]()
        additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        firstAdditional = additionalArray
        let request = getCreateRequest(amount: amount, additionalArray: additionalArray)
        doCreateInternetTransfer(request: request) { response, error in
            self.dismissActivity()
            self.animationShow(self.goButton)
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if InternetTVApiRequests.isSingleService {
                    self.doConfirmation(response: response)
                } else {
                    if let respUnw = response {
                        if respUnw.data?.needSum ?? false {
                            self.showFinalStep()
                        } else {
                            self.setupNextStep(respUnw)
                        }
                    }
                }
            }
            self.setupCardList { error in
                guard let error = error else { return }
                self.showAlert(with: "Ошибка", and: error)
            }
        }
    }

    func requestNextCreateInternetTransfer(amount: String) {
        showActivity()
        var additionalArray = [[String: String]]()
        additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        stepsPayment.append(additionalArray)
        let request = getNextStepRequest(amount: amount, additionalArray: additionalArray)
        doNextStepServiceTransfer(request: request) { response, error in
            self.dismissActivity()
            self.animationShow(self.goButton)
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if let respUnw = response {
                    if respUnw.data?.finalStep ?? false {
                        self.doConfirmation(response: respUnw)
                    } else {
                        if respUnw.data?.needSum ?? false {
                            self.showFinalStep()
                        } else {
                            self.setupNextStep(respUnw)
                        }
                    }
                }
            }
        }
    }

    func doConfirmation(response: CreateTransferAnswerModel?) {
        let ob = ConfirmViewControllerModel(type: .gkh)
        let sum = response?.data?.debitAmount ?? 0.0
        ob.summTransction = sum.currencyFormatter(symbol: "RUB")
        let tax = response?.data?.fee ?? 0.0
        ob.taxTransction = tax.currencyFormatter(symbol: "RUB")

        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.title = "Подтвердите реквизиты"
            vc.confurmVCModel = ob
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

    func setupNextStep(_ answer: CreateTransferAnswerModel) {
        answer.data?.additionalList?.forEach { item in
            let param = Requisite()
            param.subTitle = ""
            param.id = item.fieldName
            param.title = item.fieldTitle
            param.content = item.fieldValue
            param.readOnly = true
            if (requisites.first { requisite in requisite.id == param.id  } == nil) {
                requisites.append(param)
            }
        }

        answer.data?.parameterListForNextStep?.forEach { item in
            let param = Requisite.convertParameter(item)
            requisites.append(param)
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        if InternetTVApiRequests.isSingleService {
            animationHidden(goButton)
            animationShow(bottomInputView)
        } else {
            animationHidden(goButton)
            if firstStep {
                firstStep = false
                requestCreateInternetTransfer(amount: "null")
            } else {
                requestNextCreateInternetTransfer(amount: "null")
            }
        }
    }

    final func animationHidden (_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 0
            }
            view.isHidden = true
        }
    }

    final func animationShow (_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 1
            }
            view.isHidden = false
        }
    }

    final func animateQueue (_ view_1: UIView, _ view_2: UIView) {
        UIView.animateKeyframes(withDuration: 0.3, delay: .zero, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                view_1.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                view_2.alpha = 0.0
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        qrData.removeAll()
    }

    func setupNavBar() {
        let operatorsName = operatorData?.name ?? ""
        let inn = operatorData?.synonymList.first ?? ""
        navigationItem.titleView = setTitle(title: operatorsName, subtitle: "ИНН " +  inn )

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit

        if operatorData?.logotypeList.first?.content != nil {
            UserDefaults.standard.set(operatorData?.logotypeList.first?.content ?? "", forKey: "OPERATOR_IMAGE")
            let dataDecoded : Data = Data(base64Encoded: operatorData?.logotypeList.first?.content ?? "", options: .ignoreUnknownCharacters)!
            let decodedImage = UIImage(data: dataDecoded)
            imageView.image = decodedImage
            imageView.setDimensions(height: 30, width: 30)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        } else {
            imageView.image = UIImage(named: "GKH")
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func setTitle(title:String, subtitle:String) -> UIView {
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

    func getCreateRequest(amount: String, additionalArray: [[String: String]]) -> [String: AnyObject] {
        var request = [String: AnyObject]()
        if footerView.cardFromField.cardModel?.productType == "ACCOUNT" {
            let id = footerView.cardFromField.cardModel?.id ?? -1
            request = [ "check" : false,
                        "amount" : amount,
                        "currencyAmount" : "RUB",
                        "payer" : [ "cardId" : nil,
                                    "cardNumber" : nil,
                                    "accountId" : id ],
                        "puref" : puref,
                        "additional" : additionalArray] as [String: AnyObject]

        } else if footerView.cardFromField.cardModel?.productType ==  "CARD" {
            let id = footerView.cardFromField.cardModel?.id ?? -1
            request = [ "check" : false,
                        "amount" : amount,
                        "currencyAmount" : "RUB",
                        "payer" : [ "cardId" : id,
                                    "cardNumber" : nil,
                                    "accountId" : nil ],
                        "puref" : puref,
                        "additional" : additionalArray] as [String: AnyObject]
        }
        return request
    }

    func getNextStepRequest(amount: String, additionalArray: [[String: String]]) -> [String: AnyObject] {
        var request = [String: AnyObject]()
        request = [ "amount" : amount,
                    "additional" : additionalArray] as [String: AnyObject]
        return request
    }

    func doCreateInternetTransfer(request: [String: AnyObject], completion: @escaping (CreateTransferAnswerModel?, String?) -> ()) {
        NetworkManager<CreateTransferAnswerModel>.addRequest(.createInternetTransfer, [:], request) { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                completion(respModel, nil)
            } else {
                completion(nil, respModel.errorMessage)
            }
        }
    }

    func doNextStepServiceTransfer(request: [String: AnyObject], completion: @escaping (CreateTransferAnswerModel?, String?) -> ()) {
        NetworkManager2<CreateTransferAnswerModel>.addRequest(.nextStepServiceTransfer, [:], request) { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                completion(respModel, nil)
            } else {
                completion(nil, respModel.errorMessage)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requisites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InternetTVInputCell.reuseId, for: indexPath) as! InternetTVInputCell
        guard requisites.count != 0 else { return cell }

        cell.setupUI(indexPath.row, (requisites[indexPath.row]), qrData)
        cell.tableViewDelegate = (self as InternetTableViewDelegate)

        cell.showInfoView = { value in
            let infoView = GKHInfoView()
            infoView.lable.text = value
            self.showAlert(infoView)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 80.0
        return height
    }

    func afterClickingReturnInTextField(cell: InternetTVInputCell) {
        let fieldId = cell.body["fieldid"]
        let value = cell.body["fieldvalue"]
        let fieldName = cell.body["fieldname"]
        additionalElement["fieldid"] = fieldId
        additionalElement["fieldname"] = fieldName
        additionalElement["fieldvalue"] = value
        additionalDic[fieldName ?? "-1"] = additionalElement
        let item = requisites.first { requisite in requisite.id == fieldName }
        item?.content = value
        item?.readOnly = true
    }
}

@objc protocol InternetTableViewDelegate: NSObjectProtocol{
    func afterClickingReturnInTextField(cell: InternetTVInputCell)
}

class InternetTVInputCell: UITableViewCell, UITextFieldDelegate {
    static let reuseId = "InternetTVInputCell"
    var info = ""
    var showInfoView: ((String) -> ())? = nil
    var showGoButton: ((Bool) -> ())? = nil

    weak var tableViewDelegate: InternetTableViewDelegate?

    var fieldId = ""
    var fieldName = ""
    var fieldValue = ""
    var item: Requisite?
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
        fieldValue = textField.text ?? ""
    }

    func setupUI (_ index: Int, _ item: Requisite, _ qrData: [String: String]) {
        infoButon.isHidden = true
        self.item = item
        fieldId = String(index + 1)
        fieldName = item.id ?? ""
        let q = GKHDataSorted.a(item.title ?? "")
        DispatchQueue.main.async {
            self.operatorsIcon.image = UIImage(named: q.1)
        }
        textField.placeholder = q.0
        placeholder = q.0
        textField.text = item.content
        if q.0 == "Лицевой счет" {
            let qr = qrData.filter { $0.key == "Лицевой счет"}
            if let qrUnw = qr.first?.value, qrUnw != "" {
                textField.text = qrUnw
            }
        }
        if q.0 == "" {
            textField.placeholder = item.title
        }
        if q.0 == "ФИО" {
            showFioButton.isHidden = false
        } else {
            showFioButton.isHidden = true
        }
        if item.subTitle != nil {
            info = item.subTitle ?? ""
            infoButon.isHidden = false
        }
        if item.readOnly {
            textField.isEnabled = false
        } else {
            textField.isEnabled = true
        }
    }

    @IBAction func textField(_ sender: UITextField) {
        print("proc01 textField afterClickingReturnInTextField")
        fieldValue = textField.text ?? ""
        body.updateValue(fieldId, forKey: "fieldid")
        body.updateValue(fieldName, forKey: "fieldname")
        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()
        tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)

        print("proc01 shouldChangeCharactersIn \(updatedText)")
        fieldValue = updatedText
        body.updateValue(fieldId, forKey: "fieldid")
        body.updateValue(fieldName, forKey: "fieldname")
        body.updateValue(fieldValue , forKey: "fieldvalue")
        perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()
        tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)

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

        if ( fieldValue != "" && isSelect == true) {
            showGoButton?(true)
        } else if ( fieldValue == "" && isSelect == false) {
            showGoButton?(true)
        }
        if ( fieldValue == "" && isSelect == true) {
            showGoButton?(false)
        }
    }

    final func emptyCell() -> Bool {
        var result = false
        if ( fieldId != "" || fieldName != "" || fieldValue != "" ) {
            result = true
        }
        return result
    }
}

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

class Requisite {
    static func convertParameter(_ item: Parameters) -> Requisite {
        let ob = Requisite()
        ob.id = item.id
        ob.order = item.order
        ob.title = item.title
        ob.subTitle = item.subTitle
        ob.viewType = item.viewType
        ob.dataType = item.dataType
        ob.type = item.type
        ob.mask = item.mask
        ob.regExp = item.regExp
        ob.maxLength = item.maxLength
        ob.minLength = item.minLength
        ob.rawLength = item.rawLength
        ob.readOnly = item.readOnly
        ob.content = item.content
        return  ob
    }

    static func convertParameter(_ item: ParameterListForNextStep2) -> Requisite {
        let ob = Requisite()
        ob.id = item.id
        ob.order = item.order ?? 0
        ob.title = item.title
        ob.subTitle = item.subTitle
        ob.viewType = item.viewType
        ob.dataType = item.dataType
        ob.type = item.type
        ob.mask = item.mask
        ob.regExp = item.regExp
        ob.maxLength = item.maxLength ?? 0
        ob.minLength = item.minLength ?? 0
        ob.rawLength = item.rawLength ?? 0
        ob.readOnly = item.readOnly ?? false
        ob.content = item.content
        return  ob
    }

    var id: String?
    var order = 0
    var title: String?
    var subTitle: String?
    var viewType: String?
    var dataType: String?
    var type: String?
    var mask: String?
    var regExp: String?
    var maxLength = 0
    var minLength = 0
    var rawLength = 0
    var readOnly = true
    var content: String?
}