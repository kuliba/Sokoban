import UIKit
import RealmSwift
import Foundation


class InternetTVDetailsFormController: BottomPopUpViewAdapter, UITableViewDataSource, InternetTableViewDelegate, IMsg, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    static var iMsg: IMsg? = nil
    static let msgHideLatestOperation = 1
    static let msgIsSingleService = 2
    static let msgUpdateTable = 3

    var operatorData: GKHOperatorsModel?
    var latestOperation: InternetLatestOpsDO?
    var qrData = [String: String]()
    var viewModel = InternetTVDetailsFormViewModel()

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
        viewModel.controller = self
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
        viewModel.puref = operatorData?.puref ?? ""
        InternetTVApiRequests.isSingleService(puref: viewModel.puref)
        tableView.register(UINib(nibName: "InternetInputCell", bundle: nil), forCellReuseIdentifier: InternetTVInputCell.reuseId)
//        tableView.register(GKHInputFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionFooter")
        bottomInputView.currencySymbol = "₽"
        AddAllUserCardtList.add {}

        bottomInputView.didDoneButtonTapped = { amount in
            self.showActivity()
            if InternetTVApiRequests.isSingleService {
                if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
                    self.viewModel.requestCreateServiceTransfer(amount: amount)
                }
                if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
                    self.viewModel.requestCreateInternetTransfer(amount: amount)
                }
            } else {
                if !self.viewModel.firstStep {
                    self.viewModel.retryPayment(amount: amount)
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
                let req = RequisiteDO.convertParameter(item)
                if (viewModel.requisites.first { requisite in requisite.id == req.id  } == nil) {
                    viewModel.requisites.append(req)
                }
            }
            tableView.reloadData()
        }
    }

    func showFinalStep() {
        animationHidden(goButton)
        animationShow(bottomInputView)
    }

    func doConfirmation(response: CreateTransferAnswerModel?) {
        let ob = ConfirmViewControllerModel(type: .gkh)
        let sum = response?.data?.debitAmount ?? 0.0
        ob.summTransction = sum.currencyFormatter(symbol: "RUB")
        let tax = response?.data?.fee ?? 0.0
        ob.taxTransction = tax.currencyFormatter(symbol: "RUB")

        DispatchQueue.main.async {
            if let logo = self.operatorData?.logotypeList, logo.count > 0  {
                ConfirmViewControllerModel.svgIcon = logo[0].svgImage ?? ""
            }

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
            let param = RequisiteDO()
            param.subTitle = ""
            param.id = item.fieldName
            param.title = item.fieldTitle
            param.content = item.fieldValue
            param.readOnly = true
            if (viewModel.requisites.first { requisite in requisite.id == param.id  } == nil) {
                viewModel.requisites.append(param)
            }
        }

        answer.data?.parameterListForNextStep?.forEach { item in
            let param = RequisiteDO.convertParameter(item)
            if (viewModel.requisites.first { requisite in requisite.id == param.id  } == nil) {
                viewModel.requisites.append(param)
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
            if let msg = answer.data?.infoMessage {
                let infoView = GKHInfoView()
                infoView.label.text = msg
                self.showAlert(infoView)
            }
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
            if viewModel.firstStep {
                viewModel.firstStep = false
                if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
                    viewModel.requestCreateServiceTransfer(amount: "null")
                }
                if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
                    viewModel.requestCreateInternetTransfer(amount: "null")
                }
            } else {
                viewModel.requestNextCreateInternetTransfer(amount: "null")
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
//
//                filterProduct.append(card)
//                self.footerView.cardListView.cardList = filterProduct
//                self.footerView.cardFromField.cardModel = filterProduct.first
//                self.viewModel.cardNumber  = filterProduct.first?.accountNumber ?? ""
//            }
//        }

        viewModel.getCardList { [weak self] data ,error in
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
                self?.viewModel.cardNumber  = arrProducts.first?.number ?? ""
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

    func afterClickingReturnInTextField(cell: InternetTVInputCell) {
//        let fieldId = cell.body["fieldid"]
//        let value = cell.body["fieldvalue"]
//        let fieldName = cell.body["fieldname"]
        //InternetTVDetailsFormViewModel.additionalDic[fieldName ?? "-1"] = ["fieldid" : fieldId, "fieldname" : fieldName, "fieldvalue" : value]
//        let item = requisites.first { requisite in requisite.id == fieldName }
//        item?.content = value
//        item?.readOnly = true
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .custom
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //super.prepare(for: segue, sender: sender)
        if let tvc = segue.destination as? InternetTVSelectController
        {

            tvc.transitioningDelegate = self
            tvc.modalPresentationStyle = .custom

            if let ppc = tvc.popoverPresentationController
            {

                //ppc.delegate = self
                //ppc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: UIPopoverArrowDirection.up.rawValue)
                //tvc.transitioningDelegate = self
                //tvc.modalPresentationStyle = .custom


                //let view = InternetTVSelectDialog()
                //ppc.sourceView = view
                //ppc.sourceRect = view.frame

//                dialog.modalPresentationStyle = .popover
//                dialog.popoverPresentationController?.delegate = self
//                dialog.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//                dialog.popoverPresentationController?.sourceView = view
//                dialog.popoverPresentationController?.sourceRect = view.frame
            }
        }
    }

    var heightForSelectVC = 400
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = heightForSelectVC
        return presenter
    }
}

@objc protocol InternetTableViewDelegate: NSObjectProtocol{
    func afterClickingReturnInTextField(cell: InternetTVInputCell)
}

extension  InternetTVDetailsFormController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.requisites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InternetTVInputCell.reuseId, for: indexPath) as! InternetTVInputCell
        guard viewModel.requisites.count != 0 else { return cell }
        cell.setupUI(indexPath.row, (viewModel.requisites[indexPath.row]), qrData, additionalList: latestOperation?.additionalList ?? [AdditionalListModel]())
        cell.tableViewDelegate = (self as InternetTableViewDelegate)

        cell.showInfoView = { value in
            let infoView = GKHInfoView()
            infoView.label.text = value
            self.showAlert(infoView)
        }

        cell.showSelectView = { value , elementID in
            self.heightForSelectVC = 150 + (value.count * 50)
            let popView = SelectVC()
            popView.spinnerValues = value
            popView.elementID = elementID
            popView.modalPresentationStyle = .custom
            popView.transitioningDelegate = self
            self.present(popView, animated: true, completion: nil)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 80.0
        return height
    }

}
