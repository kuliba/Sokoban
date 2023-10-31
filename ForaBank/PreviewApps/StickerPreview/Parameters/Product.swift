//
//  Product.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    struct Product: Hashable {
        
        let state: State
        let selectedProduct: Option
        let allProducts: [Option]
        
        struct Option: Hashable {
            
            let paymentSystem: String
            let background: String
            let title: String
            let nameProduct: String
            let balance: String
            let description: String
        }
        
        enum State {
            
            case select
            case list
        }
    }
}

extension Operation.Parameter.Product {
    
    var parameterState: ProductStateViewModel.State {
        
        switch self.state {
        case .select:
            return .selected(.mapper(self))
        case .list:
            return .list(.mapper(self),[ProductViewModel(header: .init(title: "123"), main: .init(cardLogo: .init(""), paymentSystem: nil, name: "123", balance: "123"), footer: .init(description: "1234"))])
        }
    }
}
