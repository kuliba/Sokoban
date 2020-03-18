//
//  Currency.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 18.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

class Currency{
    let buyCurrency: Double?
    let saleCurrency: Double?
    let rateCBCurrency: Double?
    
    init(buyCurrency: Double? = nil, saleCurrency: Double? = nil, rateCBCurrency: Double? = nil) {
        self.buyCurrency = buyCurrency
        self.saleCurrency = saleCurrency
        self.rateCBCurrency = rateCBCurrency
    }
}
