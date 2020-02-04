//
//  TransferConfirmation.swift
//  ForaBank
//
//  Created by Дмитрий on 30.01.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import ReSwift

class TransferConfirmation: UIViewController    {
    

    @IBOutlet weak var kppNumber: CustomTextField!
    @IBOutlet weak var innNumber: CustomTextField!
    @IBOutlet weak var bikNumber: CustomTextField!
    @IBOutlet weak var numberAccountPayer: CustomTextField!
    @IBOutlet weak var amount: CustomTextField!
    @IBOutlet weak var comment: CustomTextField!
    var bikNumberText: String? = nil
    var innNumberText: String? = nil
    var kppNumberText: String? = nil
    var numberAccountText: String? = nil
    var commissions: Double? = nil
    var amountText: String? = nil
    @IBOutlet weak var codeNumberTextField: UITextField!
    var commentText: String? = nil
    var segueId: String? = nil

    @IBOutlet weak var sendButton: ButtonRounded!
    
    @IBAction func backButtonClicked(_ sender: Any) {
          self.navigationController?.popViewController(animated: true)
          if navigationController == nil {
              dismiss(animated: true, completion: nil)
          }
      }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bikNumber.text = bikNumberText
        innNumber.text = innNumberText
        kppNumber.text = kppNumberText
        numberAccountPayer.text = numberAccountText
        amount.text = amountText 
        comment.text = commentText
        print(commissions as Any)
        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                        if let dest = segue.destination as? PaymentsDetailsSuccessViewController {
                            dest.destinationSum.text = amountText ?? "mOE"
                        
                        }
                    }
    

        @IBAction func checkPaymentCode(_ sender: Any) {
        
            NetworkManager.shared().makeCard2Card(code: self.codeNumberTextField.text ?? "") { [weak self] (success) in
                if success {
                    self?.performSegue(withIdentifier: "toSuccess", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Неудача", message: "Неверный код", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.default, handler: { (action) in
                        let rootVC = self?.storyboard?.instantiateViewController(withIdentifier: "PaymentsFinishScreen") as! LoginOrSignupViewController
                        self?.segueId = "dismiss"
                        rootVC.segueId = "logout"
                        self?.navigationController?.setViewControllers([rootVC], animated: true)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }

    

}
