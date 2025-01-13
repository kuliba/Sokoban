//
//  ProductViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import SwiftUI
import Foundation

public struct ProductStateViewModel {
    
    var state: State
    let chevronTapped: () -> Void
    let selectOption: (ProductViewModel) -> Void
    
    public init(
        state: ProductStateViewModel.State,
        chevronTapped: @escaping () -> Void,
        selectOption: @escaping (ProductViewModel) -> Void
    ) {
        self.state = state
        self.chevronTapped = chevronTapped
        self.selectOption = selectOption
    }
}

extension ProductStateViewModel {

    public enum State {
         
        case selected(ProductViewModel)
        case list(ProductViewModel, [ProductViewModel])
    }
}

public struct ProductViewModel: Hashable {
    
    let id: Int
    let header: HeaderViewModel
    let main: MainViewModel
    let footer: FooterViewModel
}

extension ProductViewModel {
    
    public struct MainViewModel: Hashable {
    
        let cardLogo: ImageData
        let paymentSystem: ImageData?
        let name: String
        let balance: String
        let backgroundImage: ImageData?
        let backgroundColor: Color
        let clover: ImageData?
    }
    
    public struct HeaderViewModel: Hashable {
        
        let title: String
    }
    
    public struct FooterViewModel: Hashable {
        
        let description: String
    }
    
    static func mapper(
        _ product: Operation.Parameter.ProductSelector.Product
    ) -> ProductViewModel {
        
        .init(
            id: product.id,
            header: .init(title: product.title),
            main: .init(
                cardLogo: product.cardImage,
                paymentSystem: product.paymentSystem,
                name: product.nameProduct,
                balance: product.balanceFormatted,
                backgroundImage: product.backgroundImage,
                backgroundColor: Color(product.backgroundColor),
                clover: product.clover
            ),
            footer: .init(description: product.description)
        )
    }
}
