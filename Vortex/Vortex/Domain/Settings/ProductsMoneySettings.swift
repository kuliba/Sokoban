//
//  ProductsMoneyCurrencySettings.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 21.08.2022.
//

import Foundation

struct ProductsMoneySettings: Codable {
    
    var selectedCurrencyId: String
    var  selectedCurrencySymbol: String
    
    mutating func update(currencyId: String, currencySymbol: String) {
        
        selectedCurrencyId = currencyId
        selectedCurrencySymbol = currencySymbol
    }
}
