//
//  DictionaryExtensionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 22.05.2024.
//

import XCTest
@testable import ForaBank

final class DictionaryExtensionsTests: XCTestCase {

    func test_selectionAvailable_notCards_shouldReturnTrue() {
        
        let sut = makeSUT(products: makeProducts())
        
        XCTAssertTrue(sut.selectionAvailable(1))
    }
    
    func test_selectionAvailable_сardWithOutAdditional_shouldReturnTrue() {
        
        let sut = makeSUT(products: makeProducts())
        
        XCTAssertTrue(sut.selectionAvailable(8))
    }

    func test_selectionAvailable_сardOnlyOneAdditionalWithoutMain_shouldReturnTrue() {
        
        let sut = makeSUT(products: makeProducts())
        
        XCTAssertTrue(sut.selectionAvailable(9))
    }
    
    func test_selectionAvailable_сardMainWithOneAdditional_shouldReturnFalse() {
        
        let sut = makeSUT(products: makeProducts())
        
        XCTAssertFalse(sut.selectionAvailable(4))
        XCTAssertFalse(sut.selectionAvailable(6))
    }

    func test_selectionAvailable_сardMainWithManyAdditional_shouldReturnFalse() {
        
        let sut = makeSUT(products: makeProducts())
        
        XCTAssertFalse(sut.selectionAvailable(3))
        XCTAssertFalse(sut.selectionAvailable(5))
        XCTAssertFalse(sut.selectionAvailable(12))
        XCTAssertFalse(sut.selectionAvailable(7))
        XCTAssertFalse(sut.selectionAvailable(11))
        XCTAssertFalse(sut.selectionAvailable(45))
    }

    // MARK: - Helpers
    
    private func makeSUT(
        products: [ProductData]
    ) -> Array.Products {
        
        return products.groupingCards()
    }
    
    func makeProducts() -> [ProductData] {
        return [
            makeAccountProduct(id: 1),
            makeAccountProduct(id: 2),
            makeCardProduct(id: 3),
            makeCardProduct(id: 5, parentID: 3, order: 10),
            makeCardProduct(id: 12, parentID: 3, order: 0),
            makeCardProduct(id: 7, parentID: 3, order: 0),
            makeCardProduct(id: 11, parentID: 3, order: 0),
            makeCardProduct(id: 45, parentID: 3, order: 1),
            makeCardProduct(id: 6),
            makeCardProduct(id: 4, parentID: 6),
            makeCardProduct(id: 8),
            makeCardProduct(id: 9, parentID: 34)
        ]
    }
}
