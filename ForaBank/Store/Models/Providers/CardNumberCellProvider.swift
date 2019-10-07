//
//  CardNumberCellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class CardNumberCellProvider: ICellProvider {
    var currentValue: IPresentationModel?

    let iconName = "payments_transfer_between-accounts"
    let textFieldPlaceholder = "Введите номер карты или счёта"
    let cardNumberLenght = 19

    var isLoading: Bool = false

    @objc func reformatAsCardNumber(textField: UITextField) {
        guard let text = textField.text else { return }
        let formatedText = modifyCreditCardString(creditCardString: text)
        textField.text = formatedText
        currentValue = text.removeWhitespace()
    }

    func getData(completion: ([IPresentationModel]) -> ()) {

    }
}
