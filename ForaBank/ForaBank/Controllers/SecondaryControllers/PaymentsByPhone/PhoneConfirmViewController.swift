//
//  ConfirmPhoneViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 17.06.2021.
//

import UIKit

class PhoneConfirmViewController: UIViewController {

    var sbp: Bool?
    var otpCode: String?
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            isEditable: false))
    
    var payeerField = ForaInput(
        viewModel: ForaInputModel(
            title: "Получатель",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: false))
    
    var cardField = CardChooseView()
    
    var bankPayeer = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: UIImage(),
            isEditable: false,
            showChooseButton: false)
            )
    

    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: #imageLiteral(resourceName: "hash"),
            isEditable: false))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: false))
    
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
    
    @objc func showSpinningWheel(_ notification: NSNotification) {
           print(notification.userInfo ?? "")
        let otpCode = notification.userInfo?["body"] as! String
        self.otpCode = otpCode.filter { "0"..."9" ~= $0 }
        smsCodeField.text =  self.otpCode ?? ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        smsCodeField.text = otpCode ?? ""
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "otpCode"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        
        let button = UIButton(title: "Перевести")
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
            
        title = "Подтвердите реквизиты"
        let stackView = UIStackView(arrangedSubviews: [phoneField, payeerField, bankPayeer, summTransctionField, taxTransctionField, smsCodeField])
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
            let customView = UIImageView(image: sbpimage)
            let customViewItem = UIBarButtonItem(customView: customView)
            self.navigationItem.rightBarButtonItem = customViewItem
        }
        navigationController?.addCloseButton()
        
    }
    
    @objc func doneButtonTapped() {
        print(#function)
        switch sbp {
        case true:
            guard let code = smsCodeField.textField.text else { return }
            let body = ["verificationCode": code] as [String: AnyObject]
            showActivity()
            NetworkManager<AnywayPaymentMakeDecodableModel>.addRequest(.anywayPaymentMake, [:], body) { model, error in
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                }
                guard let model = model else { return }
                if model.statusCode == 0 {
                    print("DEBUG: Success payment")
                    self.dismissActivity()
                    DispatchQueue.main.async {
                        let vc = PaymentsDetailsSuccessViewController()
//                        vc.confurmVCModel =
                        var data = ConfirmViewControllerModel(type: .phoneNumberSBP)
                        vc.id = model.data?.paymentOperationDetailID
                        vc.modalPresentationStyle = .fullScreen
                        vc.printFormType = "sbp"
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
//                    DispatchQueue.main.async {
//                    if model.errorMessage == "Пользователь не авторизован"{
//                        AppLocker.present(with: .validate)
//                    }
//                    }
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                }
            }
        default:
            makeCard2Card()
        
        }
    }

    func makeCard2Card(){
           showActivity()
           guard let code = smsCodeField.textField.text else { return }
           let body = [ "verificationCode": code
                       ] as [String: AnyObject]
           NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { model, error in
               self.dismissActivity()
               if error != nil {
                   print("DEBUG: Error: ", error ?? "")
               }
               guard let model = model else { return }
               print("DEBUG: Card list: ", model)
               if model.statusCode == 0 {
                   
                   DispatchQueue.main.async {
                    let vc = PaymentsDetailsSuccessViewController()
                    
                    vc.confurmVCModel = ConfirmViewControllerModel(country: CountriesList(code: "", contactCode: "", name: "", sendCurr: nil, md5Hash: "", svgImage: "", paymentSystemCodeList: nil), model: AnywayPaymentDecodableModel(statusCode: 0, errorMessage: "", data: AnywayPayment(paymentOperationDetailID: nil, listInputs: [], error: "", errorMessage: "", finalStep: 1, id: "", amount: Double(self.summTransctionField.text.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "₽", with: "").replacingOccurrences(of: ",", with: ".")), commission: 0.0, nextStep: 0)), fullName: "")
                    vc.id = model.data?.paymentOperationDetailId
                    vc.printFormType = "internal"
                    self.navigationController?.pushViewController(vc, animated: true)
                   }
               } else {
                   print("DEBUG: Error: ", model.errorMessage ?? "")
//                DispatchQueue.main.async {
//                if model.errorMessage == "Пользователь не авторизован"{
//                    AppLocker.present(with: .validate)
//                }
//                }
               }
           }
       }
    
    
}
