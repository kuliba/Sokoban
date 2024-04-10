//
//  ProductProfileViewModelFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 10.04.2024.
//

import Foundation

struct ProductProfileViewModelFactory {
    
    let makeInfoProductViewModel: (Parameters) -> InfoProductViewModel
      
    struct Parameters {
        let model: Model
        let productData: ProductData
        let info: Bool
        let showCVV: ShowCVV?
        let events: Events
        
        init(
            model: Model,
            productData: ProductData,
            info: Bool,
            showCVV: ShowCVV? = nil,
            events: @escaping Events = { _ in }
        ) {
            self.model = model
            self.productData = productData
            self.info = info
            self.showCVV = showCVV
            self.events = events
        }
    }
    
    typealias Event = AlertEvent
    typealias Events = (Event) -> Void
}

extension ProductProfileViewModelFactory {
    
    static let preview: Self = .init(makeInfoProductViewModel: {
        _ in .sample
    })
}
