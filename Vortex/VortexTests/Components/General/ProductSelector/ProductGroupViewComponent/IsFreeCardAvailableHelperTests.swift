//
//  IsFreeCardAvailableHelperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.02.2023.
//

@testable import ForaBank
import XCTest

final class IsFreeCardAvailableHelperTests: XCTestCase {
    
    // MARK: - Free Card Policy (isFreeCardAvailable)
    
    func test_isFreeCardAvailable_shouldReturnTrue_onEmptyProducts() {
        
        XCTAssert(isFreeCardAvailable(counts: []))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onZeroCards() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.account, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onZeroCards2() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.loan, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onZeroCards3() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.account, 1), (.loan, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onOneCards() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.card, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onOneCardsAnyOther() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.card, 1), (.account, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onOneCardsAnyOther2() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.card, 1), (.loan, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnTrue_onOneCardsAnyOther3() {
        
        XCTAssert(isFreeCardAvailable(counts: [(.card, 1), (.account, 1), (.loan, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onTwoCards() {
        
        XCTAssertFalse(isFreeCardAvailable(counts: [(.card, 2)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onTwoCardsAnyOther() {
        
        XCTAssertFalse(isFreeCardAvailable(counts: [(.card, 2), (.account, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onTwoCardsAnyOther2() {
        
        XCTAssertFalse(isFreeCardAvailable(counts: [(.card, 2), (.loan, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onTwoCardsAnyOther3() {
        
        XCTAssertFalse(isFreeCardAvailable(counts: [(.card, 2), (.account, 1), (.loan, 1)]))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onThreeCards() {
        
        XCTAssertFalse(isFreeCardAvailable(
            counts: [(.card, 3)]
        ))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onThreeCardsAnyOther() {
        
        XCTAssertFalse(isFreeCardAvailable(
            counts: [(.card, 3), (.account, 5)]
        ))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onThreeCardsAnyOther2() {
        
        XCTAssertFalse(isFreeCardAvailable(
            counts: [(.card, 3), (.loan, 1)]
        ))
    }
    
    func test_isFreeCardAvailable_shouldReturnFalse_onThreeCardsAnyOther3() {
        
        XCTAssertFalse(isFreeCardAvailable(
            counts: [(.card, 3), (.account, 5), (.loan, 1)]
        ))
    }

    // MARK: - Helpers
    
    private func isFreeCardAvailable(
        maxCards: Int = 1,
        counts: ProductTypeCounts
    ) -> Bool {
        
        let settings = MainProductsGroupSettings(
            maxAllowedCardsForNewProduct: maxCards
        )
        let products = makeProductsData(counts)
        
        return settings.isFreeCardAllowed(for: products)
    }
}
