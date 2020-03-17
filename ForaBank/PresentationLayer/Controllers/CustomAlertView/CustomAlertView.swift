//
//  CustomAlertView.swift
//  ForaBank
//
//  Created by Дмитрий on 11.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class CustomAlertView: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var alertTextField: UITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var product: IProduct?
    var customName: ICustomName?
    var card: Card? = nil
    var cards: [Card] = [Card]()
    var delegate: CustomAlertViewDelegate?
    var selectedOption = "First"
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    var account: Account?
    var loan: Loan?
    var deposit: Deposit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = alertTextField.becomeFirstResponder()
        self.alertTextField.textColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        _ = alertTextField.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        guard let newName = alertTextField.text else {return}
        if loan != nil{ //меняем название кредита
            guard let loanID = loan?.loanID else {return}
            resetCustomName(id: loanID, resetName: newName, productType: .LoanType)
        }else if deposit != nil{
            guard let depositID = deposit?.id else {return}
            resetCustomName(id: depositID, resetName: newName, productType: .DepositType)
        }else if account != nil{
            guard let accountID = account?.id else {return}
            resetCustomName(id: Int(accountID), resetName: newName, productType: .AccauntType)
        }else{  //меняем название карты
            resetCartName()
        }
    }
    

}


extension CustomAlertView{
    
    private func resetCustomName(id: Int, resetName: String, productType: productTypes){
        NetworkManager.shared().saveCustomName(newName: resetName, id: id, productType: productType) { (success, errorMessage, id, name) in
            if success{
                // определяем тип продукта и посылаем уведомление нужным контроллерам 
                if productType == .AccauntType{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProductNameAccaunt"), object: resetName)
                }else if productType == .LoanType{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProductNameLoan"), object: resetName)
                }else if productType == .CardType{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customName"), object: resetName)
                }else if productType == .DepositType{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProductNameDeposit"), object: resetName)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func resetLoadName(id: Int, resetName: String){
        NetworkManager.shared().saveLoanName(newName: resetName, id: id) { (success, errorMessage, id, name) in
            NetworkManager.shared().getLoans { (success, _) in
                if success{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProductNameLoan"), object: resetName)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func resetCartName(){
        let txt = alertTextField.text
        let id = self.product?.id
        let newName:String = txt ?? "\(self.product!.name)"
            NetworkManager.shared().saveCardName(newName: newName, id:id ?? 123, completionHandler: { success, errorMessage, newName, id in })
            NetworkManager.shared().getCardList { [weak self] (success, cards) in
            self?.cards = cards ?? []
            var newName:String = txt ?? "\(self?.product!.name)"
            if newName == ""{
                    newName = (self?.product!.name)!
                         }
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customName"), object: newName)

                     }
          self.dismiss(animated: true, completion: nil)
    }
    
    
}
