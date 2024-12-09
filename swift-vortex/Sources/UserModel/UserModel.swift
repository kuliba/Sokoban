//
//  File.swift
//  
//
//  Created by Max Gribov on 06.06.2023.
//

import Foundation
import Combine

public final class UserModel<Product> {
    
    public var preferredProductValue: Product? {
        
        preferredProduct.value
    }
    public var preferredProductPublisher: AnyPublisher<Product?, Never> {
        
        preferredProduct.eraseToAnyPublisher()
    }
    private let preferredProduct = CurrentValueSubject<Product?, Never>(.none)
    
    public func setPreferredProduct(to product: Product?) {
        
        preferredProduct.value = product
    }
    
    public init() {}
}
