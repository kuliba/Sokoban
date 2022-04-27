//
//  MyProductsСurrencyMenuViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 20.04.2022.
//

import Combine
import SwiftUI

class MyProductsСurrencyMenuViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var items: [СurrencyMenuItemViewModel]
    
    init(items: [СurrencyMenuItemViewModel]) {
        
        self.items = items
    }
}

extension MyProductsСurrencyMenuViewModel {
    
    class СurrencyMenuItemViewModel: Identifiable, ObservableObject {
        
        let id: String
        let icon: Image
        let moneySign: String
        let title: String
        let subtitle: String
        
        init(id: String = UUID().uuidString,
             icon: Image,
             moneySign: String,
             title: String,
             subtitle: String) {
            
            self.id = id
            self.icon = icon
            self.moneySign = moneySign
            self.title = title
            self.subtitle = subtitle
        }
    }
}

struct MyProductsСurrencyMenuAction: Action {
    
    let moneySign: String
    let subtitle: String
}
