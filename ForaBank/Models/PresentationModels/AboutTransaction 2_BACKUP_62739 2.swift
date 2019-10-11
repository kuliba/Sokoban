//
//  AboutTransaction.swift
//  ForaBank
//
//  Created by Дмитрий on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class AboutTransaction: IAboutTransaction {
    let amount: String
    let value: String

    init(title: String, value: String) {
        self.amount = title
        self.value = value
    }
}
