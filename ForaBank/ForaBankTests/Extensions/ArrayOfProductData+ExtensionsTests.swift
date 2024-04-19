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
        
        let products: [ProductData] = [
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
        
        let groupedByParentID = products.groupingByParentID()
        
        XCTAssertNoDiff( 
            groupedByParentID.mapValues { $0.map(\.id)},
            [3:  [5, 12, 7, 11, 45],
             6:  [4],
             34: [9]
            ])
    }
}
