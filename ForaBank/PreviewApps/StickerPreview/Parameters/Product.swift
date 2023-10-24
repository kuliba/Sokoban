//
//  Product.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

extension Operation.Parameter {
    
    struct Product: Hashable {
        
        let value: String
        let title: String
        let nameProduct: String
        let balance: String
        let description: String
        let options: [Option]
        
        struct Option: Hashable {
            
            let name: String
            let balance: String
            let number: String
            let paymentSystem: String
            let background: String
        }
    }
}
