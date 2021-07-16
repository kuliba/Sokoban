//
//  PaymentByPhoneViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit
import SVGKit


class PaymentByPhoneViewController: UIViewController {
    var sbp: Bool?
    var selectBank: String?
    var confirm: Bool?
    var selectedCardNumber = ""
    var bankImage: UIImage?
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            showChooseButton: true))
    
    
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false
            ))
    
    var bankPayeer = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: UIImage(),
            isEditable: false,
            showChooseButton: true)
            )
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: true))
    
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: #imageLiteral(resourceName: "hash"),
            isEditable: false))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: true))
    
    var commentField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сообщение получателю",
            image: #imageLiteral(resourceName: "message"),
            isEditable: true))
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: #imageLiteral(resourceName: "message-square"),
            type: .smsCode))
    
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var bottomView = BottomInputView()

    
    var selectNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneField.rightButton.setImage(UIImage(imageLiteralResourceName: "addPerson"), for: .normal)
        if selectNumber != nil{
            phoneField.text = selectNumber ?? ""
        }
        view.addSubview(bottomView)
        setupUI()
        
        phoneField.didChooseButtonTapped = {() in
            self.dismiss(animated: true, completion: nil)
        }
        hideKeyboardWhenTappedAround()
        getCardList()
        
        bankPayeer.imageView.image = bankImage
        setNavigationBar()
        
        bottomView.didDoneButtonTapped = {(amount) in
            switch self.sbp{
            case true:
                self.startContactPayment(with: self.selectedCardNumber) { [self] error in
                    self.dismissActivity()
                    DispatchQueue.main.async {
                        endSBPPayment(selectBank: selectBank!, amount: bottomView.amountTextField.text ?? "0") { error in
                            print(error ?? "")
                        }
                    }
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    }
                }
            default:
                self.prepareCard2Phone()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    
    
    func setNavigationBar() {
        
        
        }
    
    @objc func doneButtonTapped() {
        switch sbp{
        case true:
            self.startContactPayment(with: selectedCardNumber) { [self] error in
                self.dismissActivity()
                DispatchQueue.main.async {
                    endSBPPayment(selectBank: selectBank!, amount: bottomView.amountTextField.text ?? "") { error in
                        print(error ?? "")
                    }
                }
                if error != nil {
                    self.showAlert(with: "Ошибка", and: error!)
                }
            }
        default:
                prepareCard2Phone()
        }
    }
    
//    override func viewWillLayoutSubviews() {
//          let width = self.view.frame.width
//          let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 40, width: width, height: 44))
//          self.view.addSubview(navigationBar)
//          let navigationItem = UINavigationItem(title: "Перевод по номеру телефона")
////          let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: nil)
//
//            let customView = UIImageView(image: #imageLiteral(resourceName: "sbp-logoDefault"))
//            let customViewItem = UIBarButtonItem(customView: customView)
//            navigationItem.rightBarButtonItem = customViewItem
//
//            let xmark = UIImageView(image: #imageLiteral(resourceName: "xmark"))
//            let xmarkItem = UIBarButtonItem(customView: xmark)
//            navigationItem.leftBarButtonItem = xmarkItem
//
//          navigationBar.setItems([navigationItem], animated: false)
//
//       }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        
        
        bankPayeer.text = selectBank ?? ""
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        bottomView.currency = "₽"

            
        title = "Перевод по номеру телефона"
        let stackView = UIStackView(arrangedSubviews: [phoneField, bankPayeer,cardField, commentField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        var sbpimage = UIImage()
//        let navImage: UIImage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
//
//        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
//        self.navigationItem.rightBarButtonItem = customViewItem
        
        
        if let paymentSystems = Dict.shared.paymentList{
        
            for system in paymentSystems{
                if system.code == "SFP"{
                    sbpimage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
                }
            }
            
        }
        
        if sbp ?? false {
            title = "Перевод через СБП"
            
            let imageView = UIImageView(image: sbpimage)
            let item = UIBarButtonItem(customView: imageView)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
            self.navigationItem.rightBarButtonItem = item
            
        }
        
        
    }
    
    
    func getCardList() {
        showActivity()
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductList, [:], [:]) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                guard let cardNumber  = model.data?.first?.number else { return }
                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    self.cardField.text = data.first?.name ?? ""
                    self.cardField.balanceLabel.text = "\(data.first?.balance ?? 0) ₽"
                    guard let maskCard = data.first?.numberMasked else { return }
                    self.cardField.bottomLabel.text = "•••• " + String(maskCard.suffix(4))
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        
    }
    
    
    func prepareCard2Phone(){
        showActivity()
        guard let number = phoneField.textField.text else {
            return
        }
        guard let sum = bottomView.amountTextField.text else {
            return
        }
        let body = ["payerCardNumber": "4656260150230695",
                    "payeePhone": "\(number)",
                    "amount": sum
                    ] as [String: AnyObject]
        NetworkManager<PrepareCard2PhoneDecodableModel>.addRequest(.prepareCard2Phone, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                self.dismissActivity()

//                guard let data  = model.data else { return }
                DispatchQueue.main.async {
                    let vc = PhoneConfirmViewController()
                    vc.sbp = self.sbp
                    vc.bankPayeer.text = self.selectBank ?? ""
                    vc.phoneField.text = self.phoneField.text
                    vc.cardField.text = self.cardField.text
                    vc.cardField.imageView.image = self.cardField.imageView.image
                    vc.summTransctionField.textField.text = self.bottomView.amountTextField.text
                    vc.taxTransctionField.isHidden = ((model.data?.commission?.isEmpty) != nil)
                    vc.bankPayeer.chooseButton.isHidden = true
                    vc.bankPayeer.imageView.image = self.bankPayeer.imageView.image
                    vc.cardField.chooseButton.isHidden = true
                    vc.payeerField.text = model.data?.payeeName ?? "Получатель не определен"
                    vc.addCloseButton()
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)                }
            } else {
                self.dismissActivity()

                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }
   
    
    
    func startContactPayment(with card: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
    
        let body = ["accountID": nil,
                    "cardID": nil,
                    "cardNumber": card,
                    "provider": nil,
                    "puref": "iFora||TransferC2CSTEP"] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], body, completion: { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(nil)
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    if error != nil {
                        self.dismissActivity()
                        print("DEBUG: Error: ", error ?? "")
                        completion(error!)
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success ")
                        completion(nil)
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        })
    }
    
    func endSBPPayment(selectBank: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
//        37477404102
        let clearAmount = amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "")
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "RecipientID",
              "fieldvalue": "0115110217" ],
            [ "fieldid": 1,
              "fieldname": "SumSTrs",
              "fieldvalue": clearAmount ]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                    self.dismissActivity()
                    self.endSBPPayment2()
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
    }
    
    func endSBPPayment2() {
        showActivity()
//        37477404102
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "BankRecipientID",
              "fieldvalue": "1crt88888881"]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                self.dismissActivity()
                print("DEBUG: Error: ", error ?? "")
                
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                self.dismissActivity()
                self.confirm = true
//                self.setupUI()
                DispatchQueue.main.async {
                    let vc = PhoneConfirmViewController()
                    vc.sbp = self.sbp
                    
                    vc.bankPayeer.text = self.selectBank ?? ""
                    vc.phoneField.text = self.phoneField.text
                    vc.cardField.text = self.cardField.text
                    vc.bankPayeer.imageView.image = self.bankPayeer.imageView.image
                    vc.summTransctionField.text = self.bottomView.amountTextField.text  ?? ""
                    vc.bankPayeer.chooseButton.isHidden = true
                    vc.cardField.chooseButton.isHidden = true
                    vc.payeerField.text = model.data?.listInputs?[5].content?[0] ?? "Получатель не найден"
                    if model.data?.commission == 0.0 {
                        vc.taxTransctionField.text = "Комиссия не взимается"
                    } else {
                        vc.taxTransctionField.text = model.data?.commission?.description ?? "Возможна комиссия"
                    }
                    vc.addCloseButton()
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                    
                }
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
                
            } else {
                self.dismissActivity()
                print("DEBUG: Error: ", model.errorMessage ?? "")
                
            }
        }
        
    }
}
