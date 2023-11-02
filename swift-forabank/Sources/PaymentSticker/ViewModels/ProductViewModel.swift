//
//  ProductViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import SwiftUI
import Foundation

struct ProductStateViewModel {
    
    var state: State
    let chevronTapped: () -> Void
    let selectOption: (Operation.Parameter.Product.Option) -> Void
}

extension ProductStateViewModel {

    enum State {
         
        case selected(ProductViewModel)
        case list(ProductViewModel, [ProductViewModel])
    }
}

struct ProductViewModel: Hashable {
    
    let header: HeaderViewModel
    let main: MainViewModel
    let footer: FooterViewModel
}

extension ProductViewModel {
    
    struct MainViewModel: Hashable {
    
        let cardLogo: String
        let paymentSystem: String?
        let name: String
        let balance: String
    }
    
    struct HeaderViewModel: Hashable {
        
        let title: String
    }
    
    struct FooterViewModel: Hashable {
        
        let description: String
    }
    
    static func mapper(_ product: Operation.Parameter.Product) -> ProductViewModel {
        
        .init(
            header: .init(title: product.selectedProduct.title),
            main: .init(
                cardLogo: .init(""),
                paymentSystem: nil,
                name: product.selectedProduct.nameProduct,
                balance: product.selectedProduct.balance
            ),
            footer: .init(description: product.selectedProduct.description)
        )
    }
}
