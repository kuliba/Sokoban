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
    let placeholder = "Введите номер счёта"
    let charactersMaxCount = 24

    var currentValue: IPresentationModel?
    var isLoading: Bool = false

    func getData(completion: ([IPresentationModel]) -> ()) {

    }
    
    func formatted(stringToFormat string: String) -> String {
        return formatedCreditCardString(creditCardString: string)
    }
}
