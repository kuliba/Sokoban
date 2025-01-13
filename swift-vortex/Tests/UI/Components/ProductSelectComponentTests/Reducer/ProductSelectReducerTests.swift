//
//  ProductSelectReducerTests.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import ProductSelectComponent
import XCTest

final class ProductSelectReducerTests: XCTestCase {
    
    func test_reduce_select_shouldNotChangeProductIfProductIsMissing() {
        
        let sut = makeSUT(products: [.test, .test2])
        let missingProduct: ProductSelect.Product = .missing
        let state: ProductSelect = .expanded(.test2, [.test, .test2])
        
        let newState = sut.reduce(state, .select(missingProduct))
        
        XCTAssertNoDiff(newState, state)
    }
    
    func test_reduce_select_shouldChangeProductToSelectedIfProductExists() {
        
        let sut = makeSUT(products: [.test, .test2])
        let existingProduct: ProductSelect.Product = .test2
        let state: ProductSelect = .expanded(.test, [.test, .test2])
        
        let newState = sut.reduce(state, .select(existingProduct))
        
        XCTAssertNoDiff(newState, .compact(existingProduct))
    }
    
    func test_reduce_toggleProductSelect_shouldExpandProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let sut = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state: ProductSelect = .compact(selectedProduct)
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, .expanded(selectedProduct, products))
    }
    
    func test_reduce_toggleProductSelect_shouldCollapseProductSelectWithSameProduct() {
        
        let products: [ProductSelect.Product] = [.test, .test2]
        let sut = makeSUT(products: products)
        let selectedProduct: ProductSelect.Product = .test2
        let state: ProductSelect = .expanded(selectedProduct, products)
        
        let newState = sut.reduce(state, .toggleProductSelect)
        
        XCTAssertNoDiff(newState, .compact(selectedProduct))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProductSelectReducer
    private typealias Spy = CallSpy<SUT.State>
    
    private func makeSUT(
        products stub: [ProductSelect.Product],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT(getProducts: { stub })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
