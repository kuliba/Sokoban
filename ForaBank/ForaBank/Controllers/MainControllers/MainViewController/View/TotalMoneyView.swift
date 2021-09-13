//
//  totalMoneyView.swift
//  ForaBank
//
//  Created by Дмитрий on 02.09.2021.
//

import UIKit

class TotalMoneyView: UIView {

    @IBOutlet weak var totalBalance: UILabel!
    /*
     Only override draw() if you perform custom drawing.
     An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
         Drawing code
    }
    */
    @IBOutlet weak var buttonView: UIView!
    
    override func draw(_ rect: CGRect) {
        self.buttonView.layer.cornerRadius = 12
        self.buttonView.alpha = 0.4

    }
  
}
