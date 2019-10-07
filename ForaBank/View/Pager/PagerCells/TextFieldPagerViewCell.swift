//
//  TextFieldPagerViewCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import FSPagerView

class TextFieldPagerViewCell: FSPagerViewCell, IConfigurableCell {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(provider: ICellProvider) {
        guard let cardNumberProvider = provider as? CardNumberCellProvider else {
            return
        }
        
        textField.placeholder = cardNumberProvider.textFieldPlaceholder
        leftButton.imageView?.image = UIImage(named: cardNumberProvider.iconName)
        
        textField.addTarget(cardNumberProvider, action: #selector(cardNumberProvider.reformatAsCardNumber), for: .editingChanged)

        //        messageLabel.text = message
    }
}
