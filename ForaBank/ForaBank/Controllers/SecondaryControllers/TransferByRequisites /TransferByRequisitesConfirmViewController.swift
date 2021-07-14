//
//  TransferByRequisitesConfirmViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 06.07.2021.
//

import UIKit

class TransferByRequisitesConfirmViewController: UIViewController {

    var byCompany: Bool?
    
    var fioField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "person"),
            isEditable: false, showChooseButton: false))
    
    var accountNumber = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер счета получателя",
            image: #imageLiteral(resourceName: "accountIcon"),
            isEditable: false))
    
    var commentField = ForaInput(
        viewModel: ForaInputModel(
            title: "Назначение платежа",
            image: #imageLiteral(resourceName: "comment"),
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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
        if byCompany == true{
            fioField.imageView.isHidden = true
            fioField.placeHolder.text = "Наименование получателя "
        }
        let stackView = UIStackView(arrangedSubviews: [fioField, accountNumber, commentField,summTransctionField, taxTransctionField, smsCodeField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        
        
        
    }
    
    @objc func doneButtonTapped() {
        makeCard2Card()
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
                   
                   DispatchQueue.main.async {
                    let vc = PaymentsDetailsSuccessViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                   }
               } else {
                   print("DEBUG: Error: ", model.errorMessage ?? "")
               }
           }
       }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
