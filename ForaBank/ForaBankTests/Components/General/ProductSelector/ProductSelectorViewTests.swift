//
//  ProductSelectorViewTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 21.08.2023.
//

@testable import ForaBank
import XCTest

final class ProductSelectorViewTests: XCTestCase {

    // MARK: - degreesForChevron tests
    
    func test_degressForChevron_isCollapseFalse_shouldReturn180() {
        
        let degress = ProductSelectorView.ViewModel.degreesForChevron(isCollapsed: false)
        
        XCTAssertNoDiff(degress, 180)
    }
    
    func test_degressForChevron_isCollapseTrue_shouldReturn0() {
        
        let degress = ProductSelectorView.ViewModel.degreesForChevron(isCollapsed: true)
        
        XCTAssertNoDiff(degress, 0)
    }
}
