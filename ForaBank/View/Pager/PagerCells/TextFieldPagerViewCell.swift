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

    var newValueCallback: ((_ newValue: IPresentationModel) -> ())?
    var charactersMaxCount: Int?
    var formattingFunc: ((String) -> (String))?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(provider: ICellProvider) {
        guard let textInputCellProvider = provider as? ITextInputCellProvider else {
            return
        }

        formattingFunc = textInputCellProvider.formatted
        charactersMaxCount = textInputCellProvider.charactersMaxCount
        newValueCallback = { (newValue) in
            textInputCellProvider.currentValue = newValue
        }

        textField.delegate = self
        textField.placeholder = textInputCellProvider.placeholder
        textField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)

        leftButton.setImage(UIImage(named: textInputCellProvider.iconName), for: .normal)
    }
}

extension TextFieldPagerViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let nonNilCharactersMaxCount = charactersMaxCount else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= nonNilCharactersMaxCount
    }

    @objc func reformatAsCardNumber(textField: UITextField) {
        guard let text = textField.text, let nonNilFormattingFunc = formattingFunc else { return }
        let formatedText = nonNilFormattingFunc(text)
        textField.text = formatedText
        newValueCallback?(cleanNumberString(string: text))
    }
}
