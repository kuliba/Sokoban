import UIKit
import RealmSwift
import Foundation


class C2BDetailsViewController: BottomPopUpViewAdapter, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    public static func storyboardInstance() -> C2BDetailsViewController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "C2BDetails") as? C2BDetailsViewController
    }

    lazy var realm = try? Realm()
    var cardFromField = CardChooseView()
    var cardListView = CardsScrollView(onlyMy: false, deleteDeposit: true, loadProducts: false)
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
    
    @IBOutlet weak var sourceHolder: UIStackView!
    
    @IBOutlet weak var viewBank: UIView!
    
    @IBOutlet weak var viewAmount: UIView!
    
    @IBOutlet var rootView: UIView!
    
    @IBAction func ActionConsent(_ sender: UISwitch) {
        showActivity()
        switchConsent.isEnabled = false
        if modeConsent == "update" {
            if let source = cardFromField.model {
                viewModel.updateContract(contractId: contractId, cardModel: source, isOff: true) { success, error in
                    self.viewModel.getConsent()
                }
            } else {
                dismissActivity()
            }
        } else {
            viewModel.createContract(cardModel: cardFromField.model!) { success, error in
                self.viewModel.getConsent()
            }
        }
    }
    
    @IBOutlet weak var labelUpperText: UILabel!
    
    @IBOutlet weak var imgAmount: UIImageView!
    
    @IBOutlet weak var labelConsentDescr: UILabel!
    
    @IBOutlet weak var switchConsent: UISwitch!
        
    @IBOutlet weak var goButton: UIButton?

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
        
        sourceHolder.addArrangedSubview(cardFromField)
        sourceHolder.addArrangedSubview(cardListView)

        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }

        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.cardFromField.model = card
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                    }
                })
            }
        }
        readAndSetupCard()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //rootView.frame.origin.y -= keyboardSize.height
            //rootView.layoutIfNeeded()
            for constraint in rootView.constraints {
                if constraint.identifier == "myBottomHolderConstr" {
                    constraint.constant -= keyboardSize.height
                }
            }
            rootView.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        for constraint in rootView.constraints {
            if constraint.identifier == "myBottomHolderConstr" {
                constraint.constant = 0
            }
        }
        rootView.layoutIfNeeded()
    }

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
                self.sourceHolder.layoutIfNeeded()
            }
        }
    }

    func hideView(_ view: UIView, needHide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.sourceHolder.layoutIfNeeded()
            }
        }
    }

    private func readAndSetupCard() {
        DispatchQueue.main.async {
            let cards = ReturnAllCardList.cards()
            var filterProduct: [UserAllCardsModel] = []
            cards.forEach({ card in
                if (card.productType == "CARD" || card.productType == "ACCOUNT") {
                    if card.currency == "RUB" {
                        filterProduct.append(card)
                    }
                }
            })
            self.cardListView.cardList = filterProduct
            self.cardFromField.model = filterProduct.first
        }
    }
    
    func updateUIFromQR(_ data: GetQRDataAnswer?) {
        dismissActivity()
        let params = data?.data?.parameters
        var bankRecipientCode = ""
        let recepientFound = params?.filter({ $0.type == "RECIPIENT" })
        if (recepientFound != nil && recepientFound?.count ?? 0 > 0) {
            C2BDetailsViewModel.recipientText = recepientFound?[0].value ?? ""
            C2BDetailsViewModel.recipientIconSrc = recepientFound?[0].icon ?? ""
            C2BDetailsViewModel.recipientDescription = recepientFound?[0].description ?? ""
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
        labelRecipient.text = C2BDetailsViewModel.recipientText
        labelRecipientDesc.text = C2BDetailsViewModel.recipientDescription
        labelAmount.text = amount
        
        if amount.isEmpty {
            viewAmount.isHidden = true
            for constraint in rootView.constraints {
                if constraint.identifier == "myTopConstr" {
                    constraint.constant = -75
                }
            }
            rootView.layoutIfNeeded()
            goButton?.isHidden = true
            bottomInputView?.isHidden = false
        } else {
            viewAmount.isHidden = false
        }
        checkSBPConsent()
        //openSuccessScreen(modelCreateC2BTransfer: nil)
    }
    
    func showFinalStep() {
        animationHidden(goButton ?? UIButton())
        animationShow(bottomInputView!)
        bottomInputView?.doneButtonIsEnabled(false)
    }

//    func doConfirmation(response: CreateTransferAnswerModel?) {
//        var ob: InternetTVConfirmViewModel? = nil
//        if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
//            ob = InternetTVConfirmViewModel(type: .gkh)
//        }
//        if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
//            ob = InternetTVConfirmViewModel(type: .internetTV)
//        }
//        if InternetTVMainViewModel.filter == GlobalModule.PAYMENT_TRANSPORT {
//            ob = InternetTVConfirmViewModel(type: .transport)
//        }
//        let sum = response?.data?.debitAmount ?? 0.0
//        ob?.sumTransaction = sum.currencyFormatter(symbol: "RUB")
//        let tax = response?.data?.fee ?? 0.0
//        ob?.taxTransaction = tax.currencyFormatter(symbol: "RUB")
//        ob?.cardFrom = cardFromField.model
//    }

    @IBAction func goButton(_ sender: UIButton) {
        doPayment(amountArg: amount)
    }
    
    private func doPayment(amountArg: String) {
        amount = amountArg
        C2BDetailsViewModel.sum = amountArg
        var cardId: String? = nil
        var accountId: String? = nil
        if let source = cardFromField.model {
            if source.productType == "ACCOUNT" {
                cardId = nil
                accountId = source.id.description
            } else if source.productType == "CARD" {
                cardId = source.id.description
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
                    "fieldvalue": viewModel.c2bLink
                ]
            ]
        ] as [String: AnyObject]
        
        showActivity()
        viewModel.createC2BTransfer(body: body) { modelCreateC2BTransfer, error in
            if (error != nil) {
                self.dismissActivity()
                self.showAlert(with: "Ошибка", and: error?.description ?? "")
            } else {
                C2BDetailsViewModel.modelCreateC2BTransfer = modelCreateC2BTransfer
                self.makeTransfer()
            }
        }
    }

    private func makeTransfer() {
        viewModel.makeTransfer { model,error in
            self.dismissActivity()
            if (error != nil) {
                self.showAlert(with: "Ошибка", and: error?.description ?? "")
            } else {
                C2BDetailsViewModel.makeTransfer = model
                self.getOperationDetailByPaymentId()
            }
        }
    }

    func getOperationDetailByPaymentId() {
        viewModel.getOperationDetailByPaymentId (idDoc: C2BDetailsViewModel.makeTransfer?.data?.paymentOperationDetailId?.description ?? "-1") { model,error in
            self.dismissActivity()
            if (error != nil) {
                self.showAlert(with: "Ошибка", and: error?.description ?? "")
            } else {
                C2BDetailsViewModel.operationDetail = model?.data
                self.openSuccessScreen()
            }
        }
    }
    
    func openSuccessScreen() {
        DispatchQueue.main.async {
            C2BDetailsViewModel.sourceModel = self.cardFromField.model
            let vc = C2BSuccessViewController()
            vc.id = C2BDetailsViewModel.modelCreateC2BTransfer?.data?.paymentOperationDetailID ?? 0
            vc.printFormType = "c2b"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func checkSBPConsent() {
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .custom
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

