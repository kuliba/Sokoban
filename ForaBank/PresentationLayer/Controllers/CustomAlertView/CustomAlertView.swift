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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertTextField.becomeFirstResponder()
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
        alertTextField.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        let txt = alertTextField.text
            let id = self.product?.id
                     var newName:String = txt ?? "\(self.product!.name)"
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
    
    @IBAction func onTapSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("First option")
            selectedOption = "First"
            break
        case 1:
            print("Second option")
            selectedOption = "Second"
            break
        default:
            break
        }
    }
}

