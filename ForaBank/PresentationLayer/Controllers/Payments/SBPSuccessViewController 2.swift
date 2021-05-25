//
//  SBPSuccessViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.04.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class SBPSuccessViewController: UIViewController {

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bank: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var sbplogo: UIImageView!
    @IBOutlet weak var successIcon: UIImageView!
    @IBOutlet weak var confirmButton: ButtonRounded!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var successLogo: UIImageView!
    @IBOutlet weak var clockLogo: UIImageView!
    
    var summ = ""
    var bankOfPayeer = ""
    var numberOfPayeer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amount.text = summ
        bank.text = bankOfPayeer
        number.text = numberOfPayeer
        successIcon.isHidden = true
        successLogo.isHidden = true
        clockLogo.isHidden = true
        confirmButton.backgroundColor = .clear
            confirmButton.layer.borderWidth = 1
            confirmButton.layer.borderColor = UIColor.white.cgColor
     
    }


    
    @IBAction func confirmInfo(_ sender: Any) {
        if confirmButton.titleLabel?.text == "Выполнить"{
        successIcon.isHidden = true
        sbplogo.isHidden = true
        clockLogo.isHidden = false
            successLogo.isHidden = false
        confirmButton.setTitle("Закрыть", for: .normal)
        confirmLabel.text = "Перевод в обработке"
            confirmLabel.textColor = .black
        } else {
            dismiss(animated: true)
            print("Hello")
        }
    }
    func dismissToRootViewController() {
         if let first = presentingViewController,
             let second = first.presentingViewController,
             let third = second.presentingViewController {

             first.view.isHidden = true
             second.view.isHidden = true
             third.dismiss(animated: false)
         }
     }
}
