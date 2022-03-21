import UIKit
import RealmSwift
import Foundation


class C2BDetailsViewController: BottomPopUpViewAdapter, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {

    public static func storyboardInstance() -> C2BDetailsViewController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "C2BDetails") as? C2BDetailsViewController
    }

    var qrData = [String: String]()
    var viewModel = C2BDetailsViewModel()
    var amount = ""
    var modeConsent = "update"
    var contractId = ""

    @IBOutlet weak var bottomInputView: BottomInputView?

    @IBOutlet weak var labelRecipient: UILabel!

    @IBOutlet weak var labelRecipientDesc: UILabel!

    @IBOutlet weak var labelAmount: UILabel!

    @IBOutlet weak var labelBank: UILabel!

    @IBOutlet weak var imgBank: UIImageView!

    @IBAction func ActionConsent(_ sender: UISwitch) {
        showActivity()
        switchConsent.isEnabled = false
        if modeConsent == "update" {
            if let source = footerView.cardFromField.cardModel {
                viewModel.updateContract(contractId: contractId, cardModel: footerView.cardFromField.cardModel!, isOff: true) { success, error in
                    self.viewModel.getConsent()
                }
            } else {
                dismissActivity()
            }
        } else {
            viewModel.createContract(cardModel: footerView.cardFromField.cardModel!) { success, error in
                self.viewModel.getConsent()
            }
        }
    }

    @IBOutlet weak var labelUpperText: UILabel!

    @IBOutlet weak var imgAmount: UIImageView!

    @IBOutlet weak var labelConsentDescr: UILabel!

    @IBOutlet weak var switchConsent: UISwitch!


    func updateUIFromQR(_ data: GetQRDataAnswer?) {
        dismissActivity()
        let params = data?.data?.parameters
        var recipientText = ""
        var recipientIconSrc = ""
        var recipientDescription = ""
        var bankRecipientCode = ""
        let recepientFound = params?.filter({ $0.type == "RECIPIENT" })
        if (recepientFound != nil && recepientFound?.count ?? 0 > 0) {
            recipientText = recepientFound?[0].value ?? ""
            recipientIconSrc = recepientFound?[0].icon ?? ""
            recipientDescription = recepientFound?[0].description ?? ""
//                    if (!recipientIconSrc.isNullOrEmpty()) {
//                        viewModel.getRecipientImage(recipientIconSrc)
//                    }
        }
        let amountFound = params?.filter({ $0.type == "AMOUNT" })
        if (amountFound != nil && amountFound?.count ?? 0 > 0) {
            amount = amountFound?[0].value ?? ""
        }
        let bankRecipientFound = params?.filter({ $0.type == "BANK" })
        if (bankRecipientFound != nil && bankRecipientFound?.count ?? 0 > 0) {
            bankRecipientCode = bankRecipientFound?[0].value ?? ""
        }
        let allBanks = Dict.shared.bankFullInfoList
        let foundBank = allBanks?.filter({ $0.memberID == bankRecipientCode })
        if foundBank != nil && foundBank?.count ?? 0 > 0 {
            let bankRusName = foundBank?[0].rusName ?? ""
            let bankIconSvg = foundBank?[0].svgImage ?? ""
            imgBank.image = bankIconSvg.convertSVGStringToImage()
            labelBank.text = bankRusName
        }
        labelRecipient.text = recipientText
        labelRecipientDesc.text = recipientDescription
        labelAmount.text = amount

        if amount.isEmpty {
            labelAmount.isHidden = true
            labelUpperText.isHidden = true
            imgAmount.isHidden = true
            goButton?.isHidden = true
            bottomInputView?.isHidden = false
        } else {
            labelAmount.isHidden = false
            labelUpperText.isHidden = false
            imgAmount.isHidden = false
        }

        checkSBMConsent()
    }

    @IBOutlet weak var goButton: UIButton?

    @IBOutlet weak var tableView: UITableView!

    lazy var realm = try? Realm()
    let footerView = InternetTVSourceView()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goButton?.isHidden = !(bottomInputView?.isHidden ?? false)
        //bottomInputView?.updateAmountUI(textAmount: latestOperation?.amount)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showActivity()
        viewModel.controller = self
        view.backgroundColor = .white
        tableView.isScrollEnabled = false
        //tableView.alwaysBounceVertical = false
        bottomInputView?.tempTextFieldValue = qrData["Сумма"] ?? "0"
        bottomInputView?.updateAmountUI(textAmount: qrData["Сумма"] ?? "0")
        bottomInputView?.isHidden = true
        setupToolbar()
        goButton?.add_CornerRadius(5)

        bottomInputView?.currencySymbol = "₽"
        AddAllUserCardtList.add {
        }

        bottomInputView?.didDoneButtonTapped = { amount in
            self.doPayment(amountArg: amount)
        }

        setupCardList { error in
            guard let error = error else {
                return
            }
            self.showAlert(with: "Ошибка", and: error)
        }

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 75
        }
    }

    func showFinalStep() {
        animationHidden(goButton ?? UIButton())
        animationShow(bottomInputView!)
        bottomInputView?.doneButtonIsEnabled(false)
    }

    func doConfirmation(response: CreateTransferAnswerModel?) {
        var ob: InternetTVConfirmViewModel? = nil
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
        ob?.cardFrom = footerView.cardFromField.cardModel
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        super.viewDidLayoutSubviews()
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height + 70
            tableView?.tableFooterView = footerView
            tableView?.layoutIfNeeded()
        }
    }

    @IBAction func goButton(_ sender: UIButton) {
        doPayment(amountArg: amount)
    }

    private func doPayment(amountArg: String) {
        amount = amountArg
        var cardId: String? = nil
        var accountId: String? = nil
        if let source = footerView.cardFromField.cardModel {
            if source.productType == "ACCOUNT" {
                cardId = nil
                accountId = source.id?.description
            } else if source.productType == "CARD" {
                cardId = source.id?.description
                accountId = nil
            }
        }

        let body = [
            "check": false,
            "amount": amountArg,
            "currencyAmount": "RUB",
            "payer": ["cardId": cardId,
                      "cardNumber": nil,
                      "accountId": accountId
            ],
            "puref": "iFora||PaymentsC2B",
            "additional": [
                [
                    "fieldid": 1,
                    "fieldname": "QRcode",
                    "fieldvalue": GlobalModule.c2bURL
                ]
            ]
        ] as [String: AnyObject]

        showActivity()
        viewModel.createC2BTransfer(body: body) { modelCreateC2BTransfer, error in
            if (error != nil) {
                self.showAlert(with: "Ошибка", and: error?.description ?? "")
            } else {
                self.viewModel.makePayment { model,error in
                    self.dismissActivity()
                    if (error != nil) {
                        self.showAlert(with: "Ошибка", and: error?.description ?? "")
                    } else {
                        DispatchQueue.main.async {
                            let vc = InternetTVSuccessViewController()
                            let viewModel = InternetTVConfirmViewModel(type: InternetTVConfirmViewModel.PaymentType.self.internetTV)
                            viewModel.sumTransaction = self.amount
                            viewModel.statusIsSuccess = true
                            vc.confirmModel = viewModel
                            vc.id = modelCreateC2BTransfer?.data?.paymentOperationDetailID ?? 0
                            vc.printFormType = "internet"
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

    func checkSBMConsent() {
        if (viewModel.consent?.count ?? 0 > 0) {
            let item = viewModel.consent?[0]
            if (item?.fastPaymentContractAttributeList?.count ?? 0 > 0) {
                let fastPayment = item?.fastPaymentContractAttributeList?[0]
                if (fastPayment != nil) {
                    if (fastPayment?.flagClientAgreementOut == "NO") {
                        modeConsent = "update"
                        contractId = fastPayment?.fpcontractID?.description ?? ""
                        switchConsent.isEnabled = true
                        switchConsent.setOn(false, animated: false)
                        goButton?.isEnabled = false
//                            binding.checkBoxConsent.setOnCheckedChangeListener { buttonView, isChecked ->
//                                if (isChecked) {
//                                    val request = UpdateFastPaymentContractRequest(
//                                        fastPayment.fpcontractID.toString(),
//                                        fastPayment.accountID.toString(),
//                                        "EMPTY",
//                                        "YES",
//                                        "YES"
//                                    )
//                                    viewModel.updateSBPConsent(request)
//                                    binding.progressBar.visibility = View.VISIBLE
//                                    binding.checkBoxConsent.isEnabled = false
//                                }
//                            }
                    } else {
                        switchConsent.setOn(true, animated: false)
                        switchConsent.isEnabled = false
                        goButton?.isEnabled = true
                    }
                } else {
                    switchConsent.setOn(true, animated: false)
                    switchConsent.isEnabled = false
                    goButton?.isEnabled = true
                }
            } else {
                switchConsent.setOn(true, animated: false)
                switchConsent.isEnabled = false
                goButton?.isEnabled = true
            }
        } else {
            modeConsent = "create"
            switchConsent.setOn(false, animated: false)
            switchConsent.isEnabled = true
            goButton?.isEnabled = false
//                binding.checkBoxConsent.setOnCheckedChangeListener { buttonView, isChecked ->
//                    if (isChecked) {
//                        viewModel.cardViewer.source.value?.let {
//                            val request = СreateFastPaymentContractRequest(
//                                it.getTransferId(),
//                                "EMPTY",
//                                "YES",
//                                "YES"
//                            )
//                            viewModel.createSBPConsent(request)
//                            binding.progressBar.visibility = View.VISIBLE
//                            binding.checkBoxConsent.isEnabled = false
//                        }
//                    }
//                }
        }
    }

    final func animationHidden(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 0
            }
            view.isHidden = true
        }
    }

    final func animationShow(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 1
            }
            view.isHidden = false
        }
    }

    final func animateQueue(_ view_1: UIView, _ view_2: UIView) {
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
    }

    func setupToolbar() {
        let operatorsName = "Оплата по QR-коду"
        navigationItem.titleView = setTitle(title: operatorsName, subtitle: "")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "back_button")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func setTitle(title: String, subtitle: String) -> UIView {
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

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.setDimensions(height: 30, width: 250)
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        titleLabel.numberOfLines = 3;

        titleLabel.anchor(left: titleView.leftAnchor, right: titleView.rightAnchor)
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

    func setupCardList(completion: @escaping (_ error: String?) -> ()) {
        //showActivity()
        var userAllCardsModelArr = [UserAllCardsModel]()
        var productListDatum: [GetProductListDatum] = []
        let object = realm?.objects(UserAllCardsModel.self)

        //dismissActivity()
        object?.forEach { product in
            if product.productType == "CARD" || product.productType == "ACCOUNT" {
                userAllCardsModelArr.append(product)
                let ob = GetProductListDatum.init(number: product.number, numberMasked: product.numberMasked, balance: product.balance, currency: product.currency, productType: product.productType, productName: product.productName, ownerID: product.ownerID, accountNumber: product.accountNumber, allowDebit: product.allowDebit, allowCredit: product.allowCredit, customName: product.customName, cardID: product.cardID, accountID: product.accountID, name: product.name, validThru: product.validThru, status: product.status, holderName: product.holderName, product: product.product, branch: product.branch, miniStatement: nil, mainField: product.mainField, additionalField: product.additionalField, smallDesign: product.smallDesign, mediumDesign: product.mediumDesign, largeDesign: product.largeDesign, paymentSystemName: product.paymentSystemName, paymentSystemImage: product.paymentSystemImage, fontDesignColor: product.fontDesignColor, id: product.id, background: [""], XLDesign: product.XLDesign, statusPC: product.statusPC, interestRate: nil, openDate: product.openDate, branchId: product.branchId, expireDate: product.expireDate, depositProductID: product.depositProductID, depositID: product.depositID, creditMinimumAmount: product.creditMinimumAmount, minimumBalance: product.minimumBalance, balanceRUB: product.balanceRUB,
                                                  isMain: product.isMain)
                productListDatum.append(ob)
            }
        }

        if (productListDatum.count > 0) {
            footerView.cardListView.cardList = productListDatum
            footerView.cardFromField.cardModel = productListDatum.first
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .custom
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tvc = segue.destination as? InternetTVSelectController {
            tvc.transitioningDelegate = self
            tvc.modalPresentationStyle = .custom
            if let ppc = tvc.popoverPresentationController {
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

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        print("back5555")
        dismiss(animated: true, completion: nil)
    }
}

extension C2BDetailsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InternetTVInputCell.reuseId, for: indexPath) as! InternetTVInputCell
        guard 0 != 0 else {
            return cell
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 80.0
        return height
    }
}
