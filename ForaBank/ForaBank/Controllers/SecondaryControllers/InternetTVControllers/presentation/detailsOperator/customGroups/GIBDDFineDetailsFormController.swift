import UIKit
import Foundation
import IQKeyboardManagerSwift

class GIBDDFineDetailsFormController: BottomPopUpViewAdapter, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {

    let model = Model.shared
    static let msgUpdateTable = 3

    public static func storyboardInstance() -> GIBDDFineDetailsFormController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "InternetTVDetail") as? GIBDDFineDetailsFormController
    }
    var fromPaymentVc = false
    var operatorData: GKHOperatorsModel?
    var customGroup: CustomGroup?
    var latestOperation: InternetLatestOpsDO?
    var qrData = [String: String]()
    var viewModel = GIBDDFineDetailsFormViewModel()
    var selectedValue = "20"
    var userInfo: ClintInfoModelData? = nil
    var template: PaymentTemplateData?
    
    @IBOutlet weak var btnContract: UIButton!
    
    @IBOutlet weak var btnTransponder: UIButton!

    @IBAction func contractAction(_ sender: Any) {
        btnContract.backgroundColor = UIColor.white
        btnTransponder.backgroundColor = UIColor.clear
        //"=,20=данным водителя / данным автомобиля,30=номеру постановления (УИН)"
        selectedValue = "20"
        initData()
    }
    
    @IBAction func transponderAction(_ sender: Any) {
        btnContract.backgroundColor = UIColor.clear
        btnTransponder.backgroundColor = UIColor.white
        //operatorData = customGroup?.childsOperators[1]
        selectedValue = "30"
        initData()
    }
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var bottomInputView: BottomInputView?
    @IBOutlet weak var goButton: UIButton?

    
    let footerView = InternetTVSourceView()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goButton?.isHidden = !(bottomInputView?.isHidden ?? false)
        bottomInputView?.updateAmountUI(textAmount: latestOperation?.amount)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.controller = self
        view.backgroundColor = .white
        bottomInputView?.tempTextFieldValue = qrData["Сумма"] ?? "0"
        bottomInputView?.isHidden = true
        setupToolbar()
        goButton?.add_CornerRadius(5)
        tableView?.register(UINib(nibName: "InternetInputCell", bundle: nil), forCellReuseIdentifier: InternetTVInputCell.reuseId)
       
//        setupCardList { error in
//            guard let error = error else { return }
//            self.showAlert(with: "Ошибка", and: error)
//        }
        readAndSetupCard()
        if fromPaymentVc == false {
            viewModel.puref = operatorData?.puref ?? ""
        }

        selectedValue = "20"
        latestOperation?.additionalList.forEach { item in
            if item.fieldName == "a3_SearchType_1_1" {
                selectedValue = item.fieldValue ?? "20"
                if selectedValue == "20" {
                    btnContract.backgroundColor = UIColor.white
                    btnTransponder.backgroundColor = UIColor.clear
                } else {
                    btnContract.backgroundColor = UIColor.clear
                    btnTransponder.backgroundColor = UIColor.white
                }
            }
        }
        
        InternetTVApiRequests.isSingleService(puref: viewModel.puref) {
            self.initData()
        }
    }

    private func initData() {
        viewModel.firstStep = true
        viewModel.requisites.removeAll()
        viewModel.additionalFields.removeAll()
        bottomInputView?.currencySymbol = "₽"
        bottomInputView?.didDoneButtonTapped = { amount in
            self.showActivity()
            if InternetTVApiRequests.isSingleService {
                    self.viewModel.doFirstStep(amount: amount)
            } else {
                if !self.viewModel.firstStep {
                    if (self.viewModel.finalStep) {
                        self.viewModel.retryPayment(amount: amount)
                    } else {
                        self.viewModel.doNextStep(amount: amount)
                    }
                }
            }
        }

        if let list = operatorData?.parameterList {
            list.forEach { item in
                if selectedValue != "-1" && (item.type == "MaskList" || item.type == "Select") {
                    if item.id == "a3_SearchType_1_1" {
                        InternetTVDetailsFormViewModel.additionalDic["fieldName"] = ["fieldid": "\(item.order ?? 0)",
                                                                                     "fieldname": item.id ?? "",
                                                                                   "fieldvalue": selectedValue]
                    }
                } else {
                    let req = RequisiteDO.convertParameter(item)
                    if let userInfoUnw = userInfo {
                        if item.id?.lowercased().contains("iregcert") == true {
                            req.content = "\(userInfoUnw.regSeries ?? "")\(userInfoUnw.regNumber ?? "")"
                        } else if item.id?.lowercased().contains("lastname") == true {
                            req.content = userInfoUnw.lastName
                        } else if item.id?.lowercased().contains("firstname") == true {
                            req.content = userInfoUnw.firstName
                        } else if item.id?.lowercased().contains("middlename") == true {
                            req.content = userInfoUnw.patronymic
                        } else if item.id?.lowercased().contains("address") == true {
                            req.content = userInfoUnw.address
                        }
                    }
                    if (viewModel.requisites.first { requisite in requisite.id == req.id  } == nil) {
                        viewModel.requisites.append(req)
                    }
                }
            }
            tableView?.reloadData()
            proceed()
        }
    }

    func showPaymentField() {
        animationHidden(goButton ?? UIButton())
        animationShow(bottomInputView!)
        //bottomInputView?.doneButtonIsEnabled(true)
        bottomInputView?.doneButtonIsEnabled(false)
    }

    func doConfirmation(response: CreateTransferAnswerModel?) {
        var ob:InternetTVConfirmViewModel? = nil
        if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
            ob = InternetTVConfirmViewModel(type: .gkh)
        }
        if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
            ob = InternetTVConfirmViewModel(type: .internetTV)
        }
        if InternetTVMainViewModel.filter == GlobalModule.PAYMENT_TRANSPORT {
            ob = InternetTVConfirmViewModel(type: .transport)
        }
        let sum = response?.data?.debitAmount ?? 0.0
        ob?.sumTransaction = sum.currencyFormatter(symbol: "RUB")
        let tax = response?.data?.fee ?? 0.0
        ob?.taxTransaction = tax.currencyFormatter(symbol: "RUB")
        ob?.cardFrom = footerView.cardFromField.model

        DispatchQueue.main.async {
            let vc = InternetTVConfirmViewController()
            vc.title = "Подтвердите реквизиты"
            vc.viewModel = ob
            vc.countryField.isHidden = true
            vc.phoneField.isHidden = true
            vc.nameField.isHidden = true
            vc.bankField.isHidden = true
            vc.numberTransactionField.isHidden = true
            vc.cardToField.isHidden = true
            vc.sumTransactionField.isHidden = false
            vc.taxTransactionField.isHidden = false
            vc.currTransactionField.isHidden = true
            vc.currencyTransactionField.isHidden = true
            InternetTVSuccessView.svgImg = self.operatorData?.logotypeList.first?.svgImage ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height + 70
            tableView?.tableFooterView = footerView
            tableView?.layoutIfNeeded()
        }
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        proceed()
    }

    private func proceed() {
        if InternetTVApiRequests.isSingleService {
            animationHidden(goButton ?? UIButton())
            animationShow(bottomInputView!)
        } else {
            animationHidden(goButton ?? UIButton())
            showActivity()
            if viewModel.firstStep {
                viewModel.firstStep = false
                    viewModel.doFirstStep(amount: "null")
            } else {
                viewModel.doNextStep(amount: "null")
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
        goButton?.isHidden = true
        qrData.removeAll()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
    }

    func setupToolbar() {
        if let template = template {
            title = template.name
            let button = UIBarButtonItem(image: UIImage(named: "edit-2"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(updateNameTemplate))
            button.tintColor = .black
            navigationItem.rightBarButtonItem = button
            
            let backButton = UIBarButtonItem(image: UIImage(named: "back_button"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(onTouchBackButton))
            backButton.tintColor = .black
            navigationItem.leftBarButtonItem = backButton
            
        } else {
            
            let operatorsName = operatorData?.name ?? ""
            let inn = operatorData?.synonymList.first ?? ""
            navigationItem.titleView = setTitle(title: operatorsName, subtitle: "ИНН " +  inn )
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.contentMode = .scaleAspectFit
            
            if let svg = operatorData?.logotypeList.first?.svgImage {
                imageView.image = svg.convertSVGStringToImage()
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
            } else {
                imageView.image = UIImage(named: "GKH")
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
            }
            navigationItem.hidesSearchBarWhenScrolling = false
            definesPresentationContext = true
        }
    }

    @objc func onTouchBackButton() {
        viewModel.closeAction()
        navigationController?.popToRootViewController(animated: true)
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
        titleView.setDimensions(height: 30, width: 250)
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

    @objc private func updateNameTemplate() {
        self.showInputDialog(title: "Название шаблона",
                             actionTitle: "Сохранить",
                             cancelTitle: "Отмена",
                             inputText: template?.name,
                             inputPlaceholder: "Введите название шаблона",
                             actionHandler:  { text in
            
            guard let text = text else { return }
            guard let templateId = self.template?.paymentTemplateId else { return }
            
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
    
    private func readAndSetupCard() {
        DispatchQueue.main.async {
            let productTypes: [ProductType] = [.card, .account]
            
            let allCards = ReturnAllCardList.cards()
            var productsFilterredMapped = [UserAllCardsModel]()
            
            productTypes.forEach { type in
                
                productsFilterredMapped += allCards.filter { $0.productType == type.rawValue && $0.currency == "RUB" }
            }

            self.footerView.cardListView.cardList = productsFilterredMapped
            
            if productsFilterredMapped.count > 0 {
                
                if let cardId = self.template?.parameterList.first?.payer.cardId {
                    
                    let card = productsFilterredMapped.first(where: { $0.id == cardId })
                    self.footerView.cardFromField.model = card
                    
                } else if let accountId = self.template?.parameterList.first?.payer.accountId {
                    
                    let card = productsFilterredMapped.first(where: { $0.id == accountId })
                    self.footerView.cardFromField.model = card
                    
                } else {
                    
                    self.footerView.cardFromField.model = productsFilterredMapped.first
                    
                }
            }
        }
    }

    func setupCardList(completion: @escaping ( _ error: String?) ->() ) {
//        showActivity()
//        var userAllCardsModelArr = [UserAllCardsModel]()
//        var productListDatum: [GetProductListDatum] = []
//        let object = realm?.objects(UserAllCardsModel.self)
//
//        dismissActivity()
//        object?.forEach { product in
//            if product.productType == "CARD" || product.productType == "ACCOUNT"  {
//                userAllCardsModelArr.append(product)
//                let ob = GetProductListDatum.init(number: product.number, numberMasked: product.numberMasked, balance: product.balance, currency: product.currency, productType: product.productType, productName: product.productName, ownerID: product.ownerID, loanID: nil, accountNumber: product.accountNumber, allowDebit: product.allowDebit, allowCredit: product.allowCredit, customName: product.customName, cardID: product.cardID, accountID: product.accountID, name: product.name, validThru: product.validThru, status: product.status, holderName: product.holderName, product: product.product, branch: product.branch, miniStatement: nil, mainField: product.mainField, additionalField: product.additionalField, smallDesign: product.smallDesign, mediumDesign: product.mediumDesign, largeDesign: product.largeDesign, paymentSystemName: product.paymentSystemName, paymentSystemImage: product.paymentSystemImage, fontDesignColor: product.fontDesignColor, id: product.id, background: [""], XLDesign: product.XLDesign, statusPC: product.statusPC, interestRate: nil, openDate: product.openDate, branchId: product.branchId, expireDate: product.expireDate, depositProductID: product.depositProductID , depositID: product.depositID, creditMinimumAmount: product.creditMinimumAmount, minimumBalance: product.minimumBalance, balanceRUB: product.balanceRUB, amount: nil, clientID: nil, currencyCode: nil, currencyNumber: nil, bankProductID: nil, finOperBrief: nil, currentInterestRate: nil, principalDebt: nil, defaultPrincipalDebt: nil, totalAmountDebt: nil, principalDebtAccount: nil, settlementAccount: nil, settlementAccountId: nil, dateLong: nil, loanBaseParam: nil, isMain: nil)
//                productListDatum.append(ob)
//            }
//        }
//
//        if (productListDatum.count > 0) {
//            footerView.cardListView.cardList = productListDatum
//            footerView.cardFromField.cardModel = productListDatum.first
//        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .custom
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

extension  GIBDDFineDetailsFormController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.requisites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InternetTVInputCell.reuseId, for: indexPath) as! InternetTVInputCell
        guard viewModel.requisites.count != 0 else { return cell }
        cell.setupUI(indexPath.row, (viewModel.requisites[indexPath.row]), qrData, additionalList: latestOperation?.additionalList ?? [AdditionalListModel](), selectedValue)

        cell.showInfoView = { value in
            let infoView = GKHInfoView()
            infoView.label.text = value
            self.showAlert(infoView)
        }

        cell.showSelectView = { value , elementID in
            let heightScreen = UIScreen.main.bounds.size.height
            self.heightForSelectVC = 150 + (value.count * 50)

            if (heightScreen - 250) < CGFloat(self.heightForSelectVC) {
                self.heightForSelectVC = Int(heightScreen - 250)
            }

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
