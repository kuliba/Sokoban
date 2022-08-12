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
        
        let count = balance.count
        
        switch UIScreen.main.bounds.width {
        case ..<280,
            280...320 where count > 14,
            320...360 where count > 16,
            360...375 where count > 18,
            375...390 where count > 20,
            390...414 where count > 22,
            414...428 where count > 23:
            return false
        default:
            return true
        }
        
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
