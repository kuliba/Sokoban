import UIKit
import IQKeyboardManagerSwift

class InternetTVConfirmViewController: UIViewController {
    
    var operatorsViewModel: OperatorsViewModel?
    
    var viewModel: InternetTVConfirmViewModel? {
        didSet {
            guard let model = viewModel else { return }
            setupData(with: model)
        }
    }
    var otpCode: String = ""
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер телефона получателя",
            image: #imageLiteral(resourceName: "Phone"),
            type: .phone,
            isEditable: false))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: false))
    
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false))
    
    var countryField = ForaInput(
        viewModel: ForaInputModel(
            title: "Страна",
            image: UIImage(named: "map-pin")!,
            isEditable: false))
    
    var numberTransactionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: UIImage(named: "hash")!,
            isEditable: false))
    
    var cardFromField = CardChooseView()
    var cardToField = CardChooseView()
    
    var sumTransactionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: UIImage(named: "coins")!,
            isEditable: false))
    
    var taxTransactionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var currTransactionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма зачисления в валюте",
            isEditable: false))
    
    var currencyTransactionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Способ выплаты",
            image: #imageLiteral(resourceName: "Frame 579"),
            isEditable: false))
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: UIImage(named: "message-square")!,
            type: .smsCode))
    
    let doneButton = UIButton(title: "Оплатить")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doneButton.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(setOtpCode(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)
    }
    
    @objc func setOtpCode(_ notification: NSNotification) {

        let otpCode: String
        
        if let dict = notification.userInfo as NSDictionary? {
            
            if let code = dict["otp"] as? String {
                
                otpCode = code
            } else if let code = dict["aps.alert.body"] as? String {
                otpCode = code
            } else {
                return
            }
        } else {
            return
        }
        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
        smsCodeField.text =  self.otpCode
    }
    
    func setupData(with model: InternetTVConfirmViewModel) {
        currTransactionField.isHidden = true
        sumTransactionField.text = model.sumTransaction
        taxTransactionField.text = model.taxTransaction
        if model.taxTransaction.isEmpty {
            taxTransactionField.isHidden = true
        }

        dismissActivity()
        cardFromField.model = model.cardFrom
        cardFromField.isHidden = false
        cardFromField.choseButton?.isHidden = true
        cardFromField.balanceLabel.isHidden = true
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.leftTitleAncor.constant = 64
        smsCodeField.textField.textContentType = .oneTimeCode
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(
            arrangedSubviews: [phoneField,
                               nameField,
                               bankField,
                               countryField,
                               numberTransactionField,
                               cardFromField,
                               cardToField,
                               sumTransactionField,
                               taxTransactionField,
                               currTransactionField,
                               currencyTransactionField,
                               smsCodeField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20)
        
        view.addSubview(doneButton)        
        doneButton.anchor(left: stackView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: stackView.rightAnchor,
                          paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 44)
    }
    
    @objc func doneButtonTapped() {
        guard var code = smsCodeField.textField.text else { return }
        if code.isEmpty {
            code = "0"
        }
        showActivity()
        let body = ["verificationCode": code] as [String: AnyObject]

        NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { response, error in
            self.dismissActivity()
            if error != nil {
                self.showAlert(with: "Ошибка", and: error ?? "")
            }
            guard let model = response else {
                return
            }

            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    let vc = InternetTVSuccessViewController()
                    self.viewModel?.statusIsSuccess = true
                    vc.confirmModel = self.viewModel
                    vc.id = model.data?.paymentOperationDetailId ?? 0
                    vc.operatorsViewModel = self.operatorsViewModel
                    if self.viewModel?.type == .gkh {
                        vc.printFormType = "housingAndCommunalService"
                        vc.confirmModel?.type = .gkh
                        if let name = self.viewModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                            
                            if self.viewModel?.template == nil {
                                self.viewModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                
                            } else {
                                self.viewModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                            }
                        }
                    } else if self.viewModel?.type == .internetTV {
                        vc.printFormType = "internet"
                        vc.confirmModel?.type = .internetTV
                        if let name = self.viewModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                            
                            if self.viewModel?.template == nil {
                                self.viewModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                
                            } else {
                                self.viewModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                            }
                        }
                    }
                    else if self.viewModel?.type == .transport {
                        vc.printFormType = "transport"
                        vc.confirmModel?.type = .transport
                        if let name = self.viewModel?.fullName, let paymentOperationDetailId = model.data?.paymentOperationDetailId {
                            
                            if self.viewModel?.template == nil {
                                self.viewModel?.templateButtonViewModel = .sfp(name: name, paymentOperationDetailId: paymentOperationDetailId)
                                
                            } else {
                                self.viewModel?.templateButtonViewModel = .template(paymentOperationDetailId)
                            }
                        }
                    }
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
}
