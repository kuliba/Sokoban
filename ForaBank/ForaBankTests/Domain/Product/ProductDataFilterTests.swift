//
//  ProductDataFilterTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 29.08.2023.
//

import XCTest
@testable import ForaBank

final class ProductDataFilterTests: XCTestCase {
    
    func test_productActiveRule_shouldReturnFalseOnStatusBlocked_card() throws {
        
        let result = makeSUT(product: .cardStub(
            status: .blocked
        ))
        
        try XCTAssertTrue(XCTUnwrap(result))
    }
    
    func test_productActiveRule_shouldReturnFalseOnStatusActive_account() throws {
        
        let result = makeSUT(product: .accountStub(
            status: .active
        ))

        try XCTAssertFalse(XCTUnwrap(result))
    }
    
    func test_productActiveRule_shouldReturnFalseOn_loan() throws {
        
        let result = makeSUT(product: .stub(
            productType: .loan
        ))
        
        XCTAssertNil(result)
    }
    
    private func makeSUT(product: ProductData) -> Bool? {
        
        ProductData.Filter.ProductActiveRule().result(product)
    }
}
