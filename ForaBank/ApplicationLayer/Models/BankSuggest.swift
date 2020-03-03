//
//  BankSuggest.swift
//  ForaBank
//
//  Created by Дмитрий on 27.01.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Mapper

class BankSuggest{
   
    var value: String?
    var bic: String?
    var kpp: String?


    init(value: String?, kpp: String) {
        self.value = value
        self.kpp = kpp
    }
}
