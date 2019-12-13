//
//  AccountNumberCellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 08.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class AccountNumberCellProvider: NSObject, ITextInputCellProvider {
    var textField: String = ""
    

    let iconName = "feed_option_accounts"
    let placeholder = "По номеру счёта"
    let charactersMaxCount = 24
    let keyboardType: UIKeyboardType = .numberPad
    let isScan = false

    var isLoading: Bool = false

    func getData(completion: ([IPresentationModel]) -> ()) {

    }

    func formatted(stringToFormat string: String) -> String {
        return formatedCreditCardString(creditCardString: string)
    }
}
