//
//  PhoneNumberCellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PhoneNumberCellProvider: NSObject, ITextInputCellProvider {

    let iconName = "payments_services_phone-billing"
    let placeholder = "Введите номер телефона"
    let charactersMaxCount = 17
    let keyboardType: UIKeyboardType = .phonePad
    
    var currentValue: IPresentationModel?
    var isLoading: Bool = false

    func getData(completion: ([IPresentationModel]) -> ()) {

    }

    func formatted(stringToFormat string: String) -> String {
        return formattedPhoneNumber(number: string)
    }
}
