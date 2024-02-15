//
//  ProductProfileReducerTests.swift
//
//
//  Created by Andryusina Nataly on 08.02.2024.
//

import XCTest
import ProductProfile

final class ProductProfileReducerTests: XCTestCase {

    // MARK: - test reduce
    
    func test_reduce_openModal_shouldSetOpenModalEffectNone() {
        
    }
    
    // MARK: - Helpers
        
    private func makeSUT(
        state: ProductProfileReducer.State,
        event: ProductProfileReducer.Event
    ) -> (ProductProfileReducer.State, ProductProfileReducer.Effect?) {
        
        return ProductProfileReducer().reduce(state, event)
    }
}
