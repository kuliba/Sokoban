//
//  PaymentByPhoneViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit

class PaymentByPhoneViewController: UIViewController {
    var sbp: Bool?
    var selectBank: String?
    var confirm: Bool?
    var selectedCardNumber = ""
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "accountImage")))
    
    
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false))
    
    var bankPayeer = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: UIImage(),
            type: .credidCard)
            )
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: true))
    
    var countryField = ForaInput(
        viewModel: ForaInputModel(
            title: "Страна",
            image: #imageLiteral(resourceName: "map-pin"),
            isEditable: false))
    
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
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var currancyTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Способ выплаты",
            image: #imageLiteral(resourceName: "Frame 579"),
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        getCardList()
        
        
        
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.title = "Перевод по номеру телефона"
        navigationController?.navigationBar.items = [UINavigationItem(title: "123")]
        let menuButton = UIButton(type: UIButton.ButtonType.system)
               menuButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        menuButton.setImage(UIImage(named: "icon_search"), for: UIControl.State())
               let menuBarButtonItem = UIBarButtonItem(customView: menuButton)

               navigationItem.leftBarButtonItems = [menuBarButtonItem]
        // Do any additional setup after loading the view.
    }
    
    
    @objc func doneButtonTapped() {
        switch sbp{
        case true:
            self.startContactPayment(with: selectedCardNumber) { [self] error in
                self.dismissActivity()
                DispatchQueue.main.async {
                    endSBPPayment(selectBank: selectBank!, amount: summTransctionField.textField.text!) { error in
                        print(error)
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
    
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.003921568627, blue: 0.1058823529, alpha: 1)
        button.layer.cornerRadius = 22
        
        bankPayeer.textField.text = selectBank
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
            
        title = "Перевод по номеру телефона"
        let stackView = UIStackView(arrangedSubviews: [phoneField, bankPayeer,cardField, summTransctionField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        
        if sbp ?? false {
            let customView = UIImageView(image: #imageLiteral(resourceName: "sbp-logoDefault"))
            let customViewItem = UIBarButtonItem(customView: customView)
            self.navigationItem.rightBarButtonItem = customViewItem
        }
    }
    
    
    func getCardList() {
        showActivity()
        NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, [:], [:]) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                guard let cardNumber  = model.data?.first?.original?.number else { return }
                self.selectedCardNumber = cardNumber
                DispatchQueue.main.async {
                    self.cardField.text = data.first?.original?.name ?? ""
                    self.cardField.balanceLabel.text = "\(data.first?.original?.balance ?? 0) ₽"
                    guard let maskCard = data.first?.original?.numberMasked else { return }
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
        let body = ["payerCardNumber": "4656260150230695",
                    "payeePhone": "9260537633",
                    "amount": 10
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
                    self.present(vc, animated: true, completion: nil)
                }
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
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(nil)
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    if error != nil {
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
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        })
    }
    
    func endSBPPayment(selectBank: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
//        37477404102
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "RecipientID",
              "fieldvalue": "0115110217" ],
            [ "fieldid": 1,
              "fieldname": "SumSTrs",
              "fieldvalue": amount ]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                DispatchQueue.main.async {
                    self.dismissActivity()
                    self.endSBPPayment2()

                }
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
            } else {
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
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
//                let model = ConfurmViewControllerModel(
//                    country: country,
//                    model: model)
//                self.goToConfurmVC(with: model)
                
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                
            }
        }
        
    }
}
