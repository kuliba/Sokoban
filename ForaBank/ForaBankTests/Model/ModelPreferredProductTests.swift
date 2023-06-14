//
//  ModelPreferredProductTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 06.06.2023.
//

import XCTest
@testable import ForaBank

final class ModelPreferredProductTests: XCTestCase {

    func test_setPreferredProductAction_preferredProductIDAndPuplisherCorrectlyUpdated() {
        
        // given
        let sut = makeSut()
        let spy = ValueSpy(sut.preferredProductIDPublisher)
        
        // when
        sut.setPreferredProductID(to: 100500)
        
        // then
        XCTAssertEqual(sut.preferredProductID, 100500)
        XCTAssertEqual(spy.values, [nil, 100500])
        
        // when
        sut.setPreferredProductID(to: nil)

        // then
        XCTAssertEqual(sut.preferredProductID, nil)
        XCTAssertEqual(spy.values, [nil, 100500, nil])
    }
    
    func test_firstProductWithFilterWithoutPreferredProduct_firstCardProduct() {
        
        // given
        let sut = makeSut([(.card, 2)])
        
        // when
        let result = sut.firstProduct(with: .generalFrom)
        
        // then
        XCTAssertEqual(result?.id, 0)
    }
    
    func test_firstProductWithFilterWithPreferredProduct_preferredProduct() {
        
        // given
        let sut = makeSut([(.card, 2)])
        sut.setPreferredProductID(to: 1)
        
        // when
        let result = sut.firstProduct(with: .generalFrom)
        
        // then
        XCTAssertEqual(result?.id, 1)
    }
    
    func test_firstProductWithFilterWithWrongPreferredProduct_firstCardProduct() {
        
        // given
        let sut = makeSut([(.card, 2)])
        sut.setPreferredProductID(to: 100500)
        
        // when
        let result = sut.firstProduct(with: .generalFrom)
        
        // then
        XCTAssertEqual(result?.id, 0)
    }
}

extension ModelPreferredProductTests {
    
    func makeSut(_ counts: ProductTypeCounts = [(.card, 1)]) -> Model {
        
        let sut = Model.mockWithEmpty()
        sut.products.value = makeProductsData(counts)
        
        return sut
    }
}
