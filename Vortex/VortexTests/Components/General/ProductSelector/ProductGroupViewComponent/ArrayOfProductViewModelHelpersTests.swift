//
//  ArrayOfProductViewModelHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.02.2023.
//

@testable import ForaBank
import XCTest

final class ArrayOfProductViewModelHelpersTests: XCTestCase {
    
    // MARK: - Reduce Array of ProductViewModel
    
    func test_reduceIsUpdating_shouldSetPropertyIsUpdating() {
        
        let count = 10
        let products = makeProductViewVMs(count: count)
        
        XCTAssert(products.map(\.isUpdating).allSatisfy { $0 == false })
        
        products.reduce(isUpdating: true)
        XCTAssert(products.map(\.isUpdating).allSatisfy { $0 == true })
        
        products.reduce(isUpdating: false)
        XCTAssert(products.map(\.isUpdating).allSatisfy { $0 == false })
    }
    
    // MARK: - Reduce Elements of Collapsible Product Group
    
    // MARK: - Count Less Than Visible
    
    func test_reduce_shouldReturnSame_onCountLessThanVisible_onCollapsed() {
        
        let count = 4
        let minVisibleCount = 5
        let isCollapsed = true
        
        let (products, reduced, _) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertEqual(products, reduced)
        XCTAssertLessThan(count, minVisibleCount)
    }
    
    func test_reduce_shouldReturnSame_onCountLessThanVisible_onNotCollapsed() {
        
        let count = 4
        let minVisibleCount = 5
        let isCollapsed = false
        
        let (products, reduced, _) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertEqual(products, reduced)
        XCTAssertLessThan(count, minVisibleCount)
    }
    
    func test_reduce_shouldNotReturnGroupButton_onCountLessThanVisible_onCollapsed() {
        
        let count = 4
        let minVisibleCount = 5
        let isCollapsed = true
        
        let (_, _, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertNil(groupButton)
        XCTAssertLessThan(count, minVisibleCount)
    }
    
    func test_reduce_shouldNotReturnGroupButton_onCountLessThanVisible_onNotCollapsed() {
        
        let count = 4
        let minVisibleCount = 5
        let isCollapsed = false
        
        let (_, _, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertNil(groupButton)
        XCTAssertLessThan(count, minVisibleCount)
    }
    
    // MARK: - Count Less Than Visible or Equal
    
    func test_reduce_shouldReturnSame_onCountEqualToVisible_onCollapsed() {
        
        let count = 5
        let minVisibleCount = 5
        let isCollapsed = true
        
        let (products, reduced, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertEqual(products, reduced)
        XCTAssertNil(groupButton)
        XCTAssertEqual(count, minVisibleCount)
    }
    
    func test_reduce_shouldReturnSame_onCountEqualToVisible_onNotCollapsed() {
        
        let count = 5
        let minVisibleCount = 5
        let isCollapsed = false
        
        let (products, reduced, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertEqual(products, reduced)
        XCTAssertNil(groupButton)
        XCTAssertEqual(count, minVisibleCount)
    }
    
    func test_reduce_shouldNotReturnGroupButton_onCountEqualToVisible_onCollapsed() {
        
        let count = 5
        let minVisibleCount = 5
        let isCollapsed = true
        
        let (_, _, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertNil(groupButton)
        XCTAssertEqual(count, minVisibleCount)
    }
    
    func test_reduce_shouldNotReturnGroupButton_onCountEqualToVisible_onNotCollapsed() {
        
        let count = 5
        let minVisibleCount = 5
        let isCollapsed = false
        
        let (_, _, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertNil(groupButton)
        XCTAssertEqual(count, minVisibleCount)
    }
    
    // MARK: - Count Greater Than Visible
    
    func test_reduce_shouldReturnSameProducts_onCountGreaterThanVisible_onNotCollapsed() {
        
        let count = 6
        let minVisibleCount = 5
        let isCollapsed = false
        
        let (products, reduced, _) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertEqual(products, reduced)
        XCTAssertGreaterThan(count, minVisibleCount)
    }
    
    func test_reduce_shouldReturnLessProducts_onCountGreaterThanVisible_onCollapsed() {
        
        let count = 6
        let minVisibleCount = 5
        let isCollapsed = true
        
        let (products, reduced, _) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertEqual(products.prefix(minVisibleCount), reduced[...])
        XCTAssertGreaterThan(count, minVisibleCount)
    }
    
    func test_reduce_shouldNotReturnGroupButton_onCountGreaterThanVisible_onNotCollapsed() {
        
        let count = 6
        let minVisibleCount = 5
        let isCollapsed = false
        
        let (_, _, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertNotNil(groupButton)
        XCTAssertGreaterThan(count, minVisibleCount)
    }
    
    func test_reduce_shouldReturnGroupButton_onCountGreaterThanVisible_onCollapsed() {
        
        let count = 6
        let minVisibleCount = 5
        let isCollapsed = true
        
        let (_, _, groupButton) = makeSUT(
            count: count,
            minVisibleCount: minVisibleCount,
            isCollapsed: isCollapsed
        )
        
        XCTAssertNotNil(groupButton)
        XCTAssertGreaterThan(count, minVisibleCount)
    }
    
    func test_countsByType_shouldBeEmpty_onEmpty() {
        let productsData = makeProductsData()
        let sut = makeProductViewVMs(from: productsData)
        
        XCTAssertEqual(sut.countsByType, [:])
    }
    
    func test_countsByType() {
        let productsData = makeProductsData([
            (.card, 3),
            (.account, 5),
            (.deposit, 7)
        ])
        let sut = makeProductViewVMs(from: productsData)
        
        XCTAssertEqual(sut.countsByType, [
            .card: 3,
            .account: 5,
            .deposit: 7
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        count: Int,
        minVisibleCount: Int,
        isCollapsed: Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        products: [ProductViewModel],
        reduced: [ProductViewModel],
        groupButton: ProductGroupView.ViewModel.GroupButtonViewModel?
    ) {
        
        let products = makeProductViewVMs(count: count)
        let (reduced, groupButton) = products.reduce(
            isCollapsed: isCollapsed,
            minVisibleCount: minVisibleCount,
            groupButtonAction: {}
        )
        
        return (products, reduced, groupButton)
    }
}
