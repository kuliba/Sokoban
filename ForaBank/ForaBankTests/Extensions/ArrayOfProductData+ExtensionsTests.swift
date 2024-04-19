//
//  ArrayOfProductData+ExtensionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 19.04.2024.
//

import XCTest
@testable import ForaBank

final class ArrayOfProductData_ExtensionsTests: XCTestCase {

    func test_groupingByParentID_shouldReturnArray() {
        
        let products = makeProducts()
        
        let groupedByParentID = products.groupingByParentID()
        
        XCTAssertNoDiff( 
            groupedByParentID.mapValues { $0.map(\.id)},
            [3:  [12, 7, 11, 45, 5],
             6:  [4],
             34: [9]
            ])
    }
    
    func test_productsWithoutAdditional_shouldReturnArray() {
        
        let products = makeProducts()
        
        let productsWithoutAdditional = products.productsWithoutAdditional()
        
        XCTAssertNoDiff(
            productsWithoutAdditional.map(\.id),
            [1, 2, 3, 6, 8])
    }
    
    func test_cardsWithoutAdditional_shouldReturnArray() {
        
        let products = makeProducts()
        
        let productsWithoutAdditional = products.cardsWithoutAdditional()
        
        XCTAssertNoDiff(
            productsWithoutAdditional.map(\.id),
            [3, 6, 8])
    }
    
    func test_productsWithoutCards_shouldReturnArray() {
        
        let products = makeProducts()
        
        let productsWithoutCards = products.productsWithoutCards()
        
        XCTAssertNoDiff(
            productsWithoutCards.map(\.id),
            [1, 2])
    }
    
    func test_groupingAndSortedProducts_shouldReturnArray() {
        
        let products = makeProducts()
        
        let groupingAndSortedProducts = products.groupingAndSortedProducts()
        
        XCTAssertNoDiff(
            groupingAndSortedProducts.map(\.id),
            [3, 12, 7, 11, 45, 5, 6, 4, 8, 9, 1, 2])
    }

    // MARK: - Helpers
    
    func makeProducts() -> [ProductData] {
        return [
            makeAccountProduct(id: 1),
            makeAccountProduct(id: 2),
            makeCardProduct(id: 5, parentID: 3, order: 10),
            makeCardProduct(id: 3),
            makeCardProduct(id: 4, parentID: 6),
            makeCardProduct(id: 6),
            makeCardProduct(id: 12, parentID: 3, order: 0),
            makeCardProduct(id: 7, parentID: 3, order: 0),
            makeCardProduct(id: 11, parentID: 3, order: 0),
            makeCardProduct(id: 8),
            makeCardProduct(id: 9, parentID: 34),
            makeCardProduct(id: 45, parentID: 3, order: 1)
        ]
    }
}
