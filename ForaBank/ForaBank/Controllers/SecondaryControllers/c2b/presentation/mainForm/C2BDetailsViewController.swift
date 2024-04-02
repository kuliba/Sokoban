import UIKit
import Foundation
import IQKeyboardManagerSwift
import Combine

class C2BDetailsViewController: BottomPopUpViewAdapter, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    public static func storyboardInstance() -> C2BDetailsViewController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "C2BDetails") as? C2BDetailsViewController
    }

    let currencySymbol = "₽"
    var cardFromField = CardChooseView()
    var cardListView = CardsScrollView(onlyMy: false, deleteDeposit: true, loadProducts: false)
    var qrData = [String: String]()
    var viewModel: C2BDetailsViewModel?
    var amount = "0.0"
    var modeConsent = "update"
    var contractId = ""
    var closeAction: () -> Void = {}
    var operationLimit = 0.0
    var getUImage: (Md5hash) -> UIImage? = { _ in UIImage() }
    
    @IBOutlet weak var viewLimit: UIView!
    
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
    
    @IBOutlet weak var btnCheckBox: UIButton!
    
    @IBAction func btnCheckBoxAction(_ sender: Any) {
        
        btnCheckBox.setImage(UIImage(named: "checkbox1"), for: .normal)
        showActivity()
        btnCheckBox.isEnabled = false
        if modeConsent == "update" {
            if let source = cardFromField.model {
                viewModel?.updateContract(contractId: contractId, cardModel: source, isOff: true) { success, error in
                    self.viewModel?.getConsent()
                }
            } else {
                dismissActivity()
            }
        } else {
            viewModel?.createContract(cardModel: cardFromField.model!) { success, error in
                self.viewModel?.getConsent()
            }
        }
    }
    
    @IBOutlet weak var labelUpperText: UILabel!
    
    @IBOutlet weak var imgAmount: UIImageView!
    
    @IBOutlet weak var labelConsentDescr: UILabel!
    
    @IBOutlet weak var goButton: UIButton?

    @IBOutlet weak var viewReceiver: UIView!

    @IBOutlet weak var recipientIcon: UIImageView!
    
    let limitAlertView = UIView()
    var limitInfoViewBottomConstraint: NSLayoutConstraint!
    var limitAlertContentLable = UILabel()
    private var bindings: Set<AnyCancellable> = []
    let model = Model.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goButton?.isHidden = !(bottomInputView?.isHidden ?? false)
        //bottomInputView?.updateAmountUI(textAmount: latestOperation?.amount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivity()
        viewModel?.controller = self
        view.backgroundColor = .white
        bottomInputView?.tempTextFieldValue = qrData["Сумма"] ?? "0"
        bottomInputView?.updateAmountUI(textAmount: qrData["Сумма"] ?? "0")
        bottomInputView?.isHidden = true
        setupToolbar()
        goButton?.add_CornerRadius(5)
        goButton?.isEnabled = false
        goButton?.backgroundColor = .lightGray
        
        bottomInputView?.currencySymbol = "₽"
        
        bottomInputView?.didDoneButtonTapped = { amount in
            self.doPayment(amountArg: amount)
        }
        
        sourceHolder.addArrangedSubview(cardFromField)
        sourceHolder.addArrangedSubview(cardListView)

        cardFromField.titleLabel.text = "Счёт списания"
        cardFromField.didChooseButtonTapped = { () in
            self.viewReceiver.isHidden = !self.viewReceiver.isHidden
            self.openOrHideView(self.cardListView)
        }

        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                self.viewReceiver.isHidden = false
                let cardList = ReturnAllCardList.cards().uniqueValues(value: {$0.accountID})
                
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
        
        view.insertSubview(limitAlertView, at: 1)
        limitAlertView.addSubview(limitAlertContentLable)
        limitAlertView.backgroundColor = .orange
        
        limitAlertContentLable.font = UIFont.boldSystemFont(ofSize: 17)
        limitAlertContentLable.textColor = .white
        limitAlertContentLable.textAlignment = .center
        limitAlertContentLable.translatesAutoresizingMaskIntoConstraints = false
        limitAlertContentLable.numberOfLines = 0
        limitAlertContentLable.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        limitAlertContentLable.topAnchor.constraint(equalTo: limitAlertView.topAnchor, constant: 10).isActive = true
        limitAlertContentLable.leadingAnchor.constraint(equalTo: limitAlertView.leadingAnchor, constant: 30).isActive = true
        limitAlertContentLable.trailingAnchor.constraint(equalTo: limitAlertView.trailingAnchor, constant: -30).isActive = true
        
        limitAlertContentLable.text = ""
        
        limitAlertView.translatesAutoresizingMaskIntoConstraints = false
        
        limitAlertView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 80).isActive = true
        limitAlertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        limitAlertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        limitAlertContentLable.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        
        limitInfoViewBottomConstraint = NSLayoutConstraint(item: limitAlertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 0)
        limitInfoViewBottomConstraint.isActive = true
        
        bind()
        model.action.send(ModelAction.Transfers.TransferLimit.Request())
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
            let clientId = Model.shared.clientInfo.value?.id
            
            self.cardListView.cardList = filterProduct.filter({$0.ownerID == clientId}).uniqueValues(value: {$0.accountID})
            let accountId = self.model.fastPaymentContractFullInfo.value.first?.fastPaymentContractAccountAttributeList?.first?.accountId
            
            if filterProduct.filter({$0.id == accountId}).count >= 1 {
                
                self.cardFromField.model = filterProduct.filter({$0.id == accountId}).first
            } else if filterProduct.filter({$0.cardID == accountId}).count >= 1 {
                
                self.cardFromField.model = filterProduct.filter({$0.cardID == accountId}).first
                
            } else {
                
                self.cardFromField.model = filterProduct.first
            }
        }
    }
    
    func updateUIFromQR(_ data: GetQRDataAnswer?) {
        dismissActivity()
        let params = data?.data?.parameters
        var bankRecipientCode = ""
        let recipientFound = params?.filter({ $0.type == "RECIPIENT" })
        if (recipientFound != nil && recipientFound?.count ?? 0 > 0) {
            C2BDetailsViewModel.recipientText = recipientFound?[0].value ?? ""
            C2BDetailsViewModel.recipientIcon = (recipientFound?[0].icon ?? "").convertSVGStringToImage()
            C2BDetailsViewModel.recipientDescription = recipientFound?[0].description ?? ""

            //                    if (!recipientIconSrc.isNullOrEmpty()) {
            //                        viewModel.getRecipientImage(recipientIconSrc)
            //                    }
        }
        let amountFound = params?.filter({ $0.type == "AMOUNT" })
        if (amountFound != nil && amountFound?.count ?? 0 > 0) {
            amount = amountFound?.first?.value ?? ""
        }
        let bankRecipientFound = params?.filter({ $0.type == "BANK" })
        if (bankRecipientFound != nil && bankRecipientFound?.count ?? 0 > 0) {
            bankRecipientCode = bankRecipientFound?.first?.value ?? ""
        }
        let allBanks = Model.shared.bankList.value
        let foundBank = allBanks.filter({ $0.memberId == bankRecipientCode })
        if foundBank.count > 0, let bankRusName = foundBank.first?.memberNameRus {
            let bankIconSvg = foundBank.first?.svgImage
            imgBank.image = bankIconSvg?.uiImage
            labelBank.text = bankRusName
            C2BSuccessView.bankImg = imgBank.image
            C2BSuccessView.bankName = bankRusName
        }
        labelRecipient.text = C2BDetailsViewModel.recipientText
        recipientIcon.image = C2BDetailsViewModel.recipientIcon
        labelRecipientDesc.text = C2BDetailsViewModel.recipientDescription

        let amountDouble = Double(amount)
        labelAmount.text = amountDouble?.currencyFormatter() //" \(currencySymbol)"
        
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
                    "fieldvalue": viewModel?.c2bLink
                ]
            ]
        ] as [String: AnyObject]
        
        showActivity()
        viewModel?.createC2BTransfer(body: body) { modelCreateC2BTransfer, error in
            if (error != nil) {
                self.dismissActivity()
                if self.cardFromField.model?.balanceRUB ?? 0.0 < self.operationLimit {
                    self.showAlert(with: "Ошибка", and: error?.description ?? "")
                } else {
                    self.showLimitInfoView(true)
                }
            } else {
                self.showLimitInfoView(false)
                C2BDetailsViewModel.modelCreateC2BTransfer = modelCreateC2BTransfer
                self.makeTransfer()
            }
        }
    }
    
    private func showLimitInfoView (_ value: Bool) {
        
        if value == true {
            self.limitInfoViewBottomConstraint.constant = 275
        } else {
            self.limitInfoViewBottomConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {

                case let payload as ModelAction.Transfers.TransferLimit.Response:
                    switch payload {
                    case .limit( let value ):
                        self.operationLimit = value.limit
                        let limit = NumberFormatter.decimal(value.limit)
                        self.limitAlertContentLable.text = "Сумма операции должна быть меньше \(limit)" + " ₽"
                    case .noLimit:
                        break
                    case .failure(let error):
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "ModelAction.Transfers.TransferLimit.Response error: \(error.localizedDescription)")
                    }
                default:
                    break
                }
            }.store(in: &bindings)
    }

    private func makeTransfer() {
        viewModel?.makeTransfer { model,error in
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

        UIApplication.shared.endEditing()

        viewModel?.getOperationDetailByPaymentId (idDoc: C2BDetailsViewModel.makeTransfer?.data?.paymentOperationDetailId?.description ?? "-1") { model,error in
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
            vc.getUImage = self.getUImage
            vc.id = C2BDetailsViewModel.modelCreateC2BTransfer?.data?.paymentOperationDetailID ?? 0
            vc.printFormType = "c2b"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func checkSBPConsent() {
        if (viewModel?.consent?.count ?? 0 > 0) {
            let item = viewModel?.consent?[0]
            if (item?.fastPaymentContractAttributeList?.count ?? 0 > 0) {
                let fastPayment = item?.fastPaymentContractAttributeList?[0]
                if (fastPayment != nil) {
                    if (fastPayment?.flagClientAgreementOut == "NO") {
                        modeConsent = "update"
                        contractId = fastPayment?.fpcontractID?.description ?? ""
                        btnCheckBox.isEnabled = true
                        btnCheckBox.setImage(UIImage(named: "checkbox0"), for: .normal)
                        goButton?.isEnabled = false
                        goButton?.backgroundColor = .lightGray
                    } else {
                        btnCheckBox.setImage(UIImage(named: "checkbox1"), for: .normal)
                        btnCheckBox.isEnabled = false
                        goButton?.isEnabled = true
                        goButton?.backgroundColor = .red

                        btnCheckBox?.isHidden = true
                        labelConsentDescr.isHidden = true
                        for constraint in rootView.constraints {
                            if constraint.identifier == "mySwitchConsent" {
                                constraint.constant = -75
                            }
                        }
                    }
                } else {
                    btnCheckBox.setImage(UIImage(named: "checkbox1"), for: .normal)
                    btnCheckBox.isEnabled = false
                    goButton?.isEnabled = true
                    goButton?.backgroundColor = .red

                    btnCheckBox.isHidden = true
                    labelConsentDescr.isHidden = true
                    for constraint in rootView.constraints {
                        if constraint.identifier == "mySwitchConsent" {
                            constraint.constant = -75
                        }
                    }
                }
            } else {
                btnCheckBox.setImage(UIImage(named: "checkbox1"), for: .normal)
                btnCheckBox.isEnabled = false
                goButton?.isEnabled = true
                goButton?.backgroundColor = .red

                btnCheckBox.isHidden = true
                labelConsentDescr.isHidden = true
                for constraint in rootView.constraints {
                    if constraint.identifier == "mySwitchConsent" {
                        constraint.constant = -75
                    }
                }
            }
        } else {
            modeConsent = "create"
            btnCheckBox.setImage(UIImage(named: "checkbox0"), for: .normal)
            btnCheckBox.isEnabled = true
            goButton?.isEnabled = false
            goButton?.backgroundColor = .lightGray
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        IQKeyboardManager.shared.enableAutoToolbar = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        goButton?.isHidden = true
        qrData.removeAll()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func setupToolbar() {
        let operatorsName = "Оплата по QR-коду"
        navigationItem.titleView = setTitle(title: operatorsName, subtitle: "")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "back_button")
//        let imageViewRight = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
//        imageViewRight.contentMode = .scaleAspectFit
//        imageViewRight.image = UIImage(named: "sbp-logo")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageViewRight)
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
        dismiss(animated: true, completion: nil)
        closeAction()
    }
}
