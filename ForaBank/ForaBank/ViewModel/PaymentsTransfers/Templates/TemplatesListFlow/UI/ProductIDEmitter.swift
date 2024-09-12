//
//  ProductIDEmitter.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.08.2024.
//

import Combine

protocol ProductIDEmitter {
    
    typealias ProductID = ProductData.ID
    
    var productIDPublisher: AnyPublisher<ProductID, Never> { get }
}
