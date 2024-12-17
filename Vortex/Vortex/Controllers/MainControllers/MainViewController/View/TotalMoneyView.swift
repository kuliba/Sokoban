//
//  totalMoneyView.swift
//  ForaBank
//
//  Created by Дмитрий on 02.09.2021.
//

import UIKit

class TotalMoneyView: UIView {

    @IBOutlet weak var totalBalance: UILabel!

    var label1 = UILabel()
    var label2 = UILabel()

    
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func draw(_ rect: CGRect) {
        self.buttonView.layer.cornerRadius = 12
        self.buttonView.alpha = 0.4

    }
    
    func stackViewAxis (_ axis: Bool) {
        if axis {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
    }
  
}
