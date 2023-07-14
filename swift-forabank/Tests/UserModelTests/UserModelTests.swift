//
//  UserModelTests.swift
//  
//
//  Created by Max Gribov on 06.06.2023.
//

import XCTest
import UserModel

final class UserModelTests: XCTestCase {

    func test_init() {
        
        let sut = makeSut()
        let spy = ValueSpy(sut.preferredProductPublisher)
        
        XCTAssertNil(sut.preferredProductValue)
        XCTAssertEqual(spy.values, [nil])
    }
    
    func test_setPreferredProduct_valueAndPublisherUpdates() {
        
        // given
        let sut = makeSut()
        let product = Product()
        let spy = ValueSpy(sut.preferredProductPublisher)
        
        // when
        sut.setPreferredProduct(to: product.id)
        
        // then
        XCTAssertEqual(sut.preferredProductValue, product.id)
        XCTAssertEqual(spy.values, [nil, product.id])
        
        // when
        sut.setPreferredProduct(to: nil)
        
        // then
        XCTAssertEqual(sut.preferredProductValue, nil)
        XCTAssertEqual(spy.values, [nil, product.id, nil])
    }
}

private extension UserModelTests {
    
    func makeSut() -> UserModel<Product.ID> {
        
        .init()
    }
}

private struct Product: Identifiable {
    
    var id: UUID = UUID()
}
