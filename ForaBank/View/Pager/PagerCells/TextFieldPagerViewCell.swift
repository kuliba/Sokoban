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
        textField.delegate = self
    }

    var maxCharactersLenght = 0

    func configure(provider: ICellProvider) {
        guard let cardNumberProvider = provider as? CardNumberCellProvider else {
            return
        }

        textField.placeholder = cardNumberProvider.textFieldPlaceholder
        leftButton.imageView?.image = UIImage(named: cardNumberProvider.iconName)
        maxCharactersLenght = cardNumberProvider.cardNumberLenght

        textField.addTarget(cardNumberProvider, action: #selector(cardNumberProvider.reformatAsCardNumber), for: .editingChanged)
    }
}

extension TextFieldPagerViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= maxCharactersLenght
    }
}
