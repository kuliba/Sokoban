//
//  PaymentOptionDropDownCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 04/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import DropDown

class PaymentOptionDropDownCell: DropDownCell {

    @IBOutlet weak var paymentOptionView: PaymentOptionView!

    let fakeLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()

        optionLabel = fakeLabel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
