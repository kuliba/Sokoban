//
//  ProductGroup.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import Foundation

public struct ProductGroup: Equatable, Identifiable {
    
    let productType: CarouselProduct.ProductType
    public var id: CarouselProduct.ProductType { productType }
    let products: [CarouselProduct]
    var state: State
    
    public init(
        productType: CarouselProduct.ProductType,
        products: [CarouselProduct],
        state: State = .collapsed
    ) {
        self.productType = productType
        self.products = products
        self.state = state
    }
    
    public enum State: Identifiable {
        
        case collapsed, expanded
        
        public var id: _Case { _case }
        
        var _case: _Case {
            
            switch self {
            case .collapsed: return .collapsed
            case .expanded: return .expanded
            }
        }
        
        public enum _Case {
            
            case collapsed, expanded
        }
        
    }
}

extension ProductGroup {
    
    func visibleProducts(count: Int) -> [CarouselProduct] {
        
        switch state {
        case .collapsed:
            return .init(products.prefix(count))
            
        case .expanded:
            return products
        }
    }
    
    func spoilerTitle(count: Int) -> String? {
        
        switch state {
        case .collapsed:
            let numberIfItemsUnderSpoiler = products.count - count
            
            guard numberIfItemsUnderSpoiler > 0
            else { return nil }
            
            return "+\(numberIfItemsUnderSpoiler)"
            
        case .expanded:
            return nil
        }
    }
}
