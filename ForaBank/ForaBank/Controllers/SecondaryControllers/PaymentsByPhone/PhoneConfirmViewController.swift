//
//  ConfirmPhoneViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 17.06.2021.
//

import UIKit

class PhoneConfirmViewController: UIViewController {

    var sbp: Bool?
    
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
  
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: #imageLiteral(resourceName: "message-square"),
            type: .smsCode))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.003921568627, blue: 0.1058823529, alpha: 1)
        button.layer.cornerRadius = 22
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
            
        title = "Перевод по номеру телефона"
        let stackView = UIStackView(arrangedSubviews: [phoneField, bankPayeer,cardField, summTransctionField, smsCodeField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        
//        if sbp ?? false {
//            let customView = UIImageView(image: #imageLiteral(resourceName: "sbp-logoDefault"))
//            let customViewItem = UIBarButtonItem(customView: customView)
//            self.navigationItem.rightBarButtonItem = customViewItem
//        }
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
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
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
           NetworkManager<MakeCard2CardDecodableModel>.addRequest(.makeCard2Card, [:], body) { model, error in
               self.dismissActivity()
               if error != nil {
                   print("DEBUG: Error: ", error ?? "")
               }
               guard let model = model else { return }
               print("DEBUG: Card list: ", model)
               if model.statusCode == 0 {
                   guard let data  = model.data else { return }
             
                   
                   DispatchQueue.main.async {
                    let vc = PaymentsDetailsSuccessViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                   }
               } else {
                   print("DEBUG: Error: ", model.errorMessage ?? "")
               }
           }
       }
    
}
