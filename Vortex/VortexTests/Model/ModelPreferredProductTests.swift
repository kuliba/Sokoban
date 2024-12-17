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
    
    func test_firstProductExcluding_shouldReturnFirstProductNotEqualExcluding() {
        
        let card1 = makeCardProduct(id: 1, cardType: .individualBusinessmanMain)
        let card2 = makeCardProduct(id: 2, cardType: .main)
        let sut = makeSUT(products: [
            .card : [card1, card2]
        ])
        
        let result = sut.firstProduct(with: .generalToWithDepositAndIndividualBusinessmanMain, excluding: card1)
        
        XCTAssertNoDiff(result?.id, card2.id)
    }
    
    func test_firstProductExcluding_emptyProducts_shouldReturnNil() {
        
        let card1 = makeCardProduct(id: 1, cardType: .individualBusinessmanMain)
        let sut = makeSUT(products: [:])
        
        let result = sut.firstProduct(with: .generalToWithDepositAndIndividualBusinessmanMain, excluding: card1)
        
        XCTAssertNil(result)
    }

    func test_firstProductExcluding_onlyOneProduct_shouldProduct() {
        
        let card = makeCardProduct(id: 1, cardType: .individualBusinessmanMain)
        let sut = makeSUT(products: [.card: [card]])
        
        let result = sut.firstProduct(with: .generalToWithDepositAndIndividualBusinessmanMain, excluding: card)
        
        XCTAssertNoDiff(result?.id, card.id)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        products: ProductsData,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut = Model.mockWithEmptyExcept()
        sut.products.value = products

        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }
    
    func makeSut(_ counts: ProductTypeCounts = [(.card, 1)]) -> Model {
        
        let sut = Model.mockWithEmptyExcept()
        sut.products.value = makeProductsData(counts)
        
        return sut
    }
}
