//
//  MyProductsMoneyViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//

import Combine
import SwiftUI

class MyProductsMoneyViewModel: ObservableObject {
    
    @Published var balance: String
    
    let title: String = "Всего денег"
    let subtitle: String
    let currencyButton: CurrencyButtonViewModel?
    
    init(subtitle: String, balance: String, currencyButton: CurrencyButtonViewModel? = nil) {
        
        self.subtitle = subtitle
        self.balance = balance
        self.currencyButton = currencyButton
    }
    
    init() {
        
        self.subtitle = "По курсу ЦБ"
        self.balance = ""
        self.currencyButton = nil
    }
}

extension MyProductsMoneyViewModel {
    
    var isSingleLineBalance: Bool {
        
        balance.count < 8 // < 10_000_000
    }
    
    func updateBalance(balance: Double) {
        
        let formatter = NumberFormatter.currency(with: "₽")
        self.balance = formatter.string(from: NSNumber(value: balance)) ?? ""
    }
}

extension MyProductsMoneyViewModel {
    
    class CurrencyButtonViewModel: ObservableObject {
        
        @Published var isSelected: Bool
        
        let icon: Image
        var title: String
        
        init(icon: Image, title: String, isSelected: Bool) {
            
            self.icon = icon
            self.title = title
            self.isSelected = isSelected
        }
    }
}

extension MyProductsMoneyViewModel {
    
    static let sample1 = MyProductsMoneyViewModel(
        subtitle: "По курсу ЦБ",
        balance: "170897",
        currencyButton: nil)
    
    static let sample2 = MyProductsMoneyViewModel(
        subtitle: "По курсу ЦБ",
        balance: "100032281773",
        currencyButton: nil)
}
