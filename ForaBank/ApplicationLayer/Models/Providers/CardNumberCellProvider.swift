//
//  CardNumberCellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class CardNumberCellProvider: NSObject, ITextInputCellProvider {

    let iconName = "payments_transfer_between-accounts"
    let placeholder = "Введите номер карты"
    let charactersMaxCount = 19
    let keyboardType: UIKeyboardType = .numberPad
    let isScan = true

    var currentValue: IPresentationModel?
    var isLoading: Bool = false

    func getData(completion: ([IPresentationModel]) -> ()) {

    }

    func formatted(stringToFormat string: String) -> String {
        return formatedCreditCardString(creditCardString: string)
    }
}
