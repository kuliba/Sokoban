//
//  SuccessPaymentViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 18.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class SuccessPaymentViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var typePayment: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var idPayment: UILabel!
    
    @IBOutlet weak var detailOperation: UIButton!
    var listInputs: [ListInput]?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let amount = listInputs?[3].content?[0], let bankName =  listInputs?[6].content?[0] else {
            return
        }
        amountLabel.text = "\(amount) ₽ "
        recipientLabel.text = listInputs?[5].content?[0]
        typeLabel.text = "В \(bankName) через СБП"
        idPayment.text = listInputs?[7].content?[0]
        // Do any additional setup after loading the view.
    }
    
    @IBAction func detailAction(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "SBPSuccessViewController") as? SBPSuccessViewController else {
                                 return
                             }
        vc.detailInformation = true
        vc.listInputs = listInputs
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backToRoot(_ sender: UIButton) {
        dismissToRootViewController()
    }
    func dismissToRootViewController() {
        if let first = presentingViewController,
            let second = first.presentingViewController,
            let third = second.presentingViewController {

            first.view.isHidden = true
            second.view.isHidden = true
            third.dismiss(animated: true)
        }
    }
    @IBAction func receiptAction(_ sender: UIButton) {
//        performSegue(withIdentifier: "segue", sender: nil)
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
