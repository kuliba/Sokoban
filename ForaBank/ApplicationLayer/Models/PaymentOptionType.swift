//
//  PaymentOptionType.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum PaymentOptionType {
    case option(PaymentOption)
    case cardNumber(String)
    case accountNumber(String)
    case phoneNumber(String)
}
