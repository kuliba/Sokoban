//
//  ProductCarouselViewViewModelContentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.02.2023.
//

@testable import ForaBank
import XCTest

final class ProductCarouselViewViewModelContentTests: XCTestCase {
    
    typealias ViewModel = ProductCarouselView.ViewModel
    
    // MARK: - firstGroup
    
    func test_firstGroup_shouldReturnNil_onEmpty() {
        
        let content: ViewModel.Content = .empty
        
        XCTAssertNil(content.firstGroup)
    }
    
    func test_firstGroup_shouldReturnNil_onPlaceholders() {
        
        let content: ViewModel.Content = .placeholders
        
        XCTAssertNil(content.firstGroup)
    }
    
    func test_firstGroup_shouldReturnNil_onEmptyGroups() {
        
        let content: ViewModel.Content = .groups([])
        
        XCTAssertNil(content.firstGroup)
    }
    
    func test_firstGroup_shouldReturnFirst_onNonEmptyGroups() {
        
        let content: ViewModel.Content = .groups(makeGroups(productTypesCounts: [(.card, 2)]))
        
        XCTAssertEqual(content.firstGroup?.id, "CARD")
    }
    
    // MARK: - firstGroup(ofType:)
    
    func test_firstGroupOfType_shouldReturnNil_onEmpty() {
        
        let content: ViewModel.Content = .empty
        
        XCTAssertNil(content.firstGroup(ofType: .card))
    }
    
    func test_firstGroupOfType_shouldReturnNil_onPlaceholders() {
        
        let content: ViewModel.Content = .placeholders
        
        XCTAssertNil(content.firstGroup(ofType: .card))
    }
    
    func test_firstGroupOfType_shouldReturnNil_onEmptyGroups() {
        
        let content: ViewModel.Content = .groups([])
        
        XCTAssertNil(content.firstGroup(ofType: .card))
    }
    
    func test_firstGroupOfType_shouldReturnFirst_onMissingInGroups() {
        
        let content: ViewModel.Content = .groups(makeGroups(productTypesCounts: [(.card, 2)]))
        
        XCTAssertNil(content.firstGroup(ofType: .account)?.id)
    }
    
    func test_firstGroupOfType_shouldReturnFirst_onGroups() {
        
        let content: ViewModel.Content = .groups(makeGroups(productTypesCounts: [(.card, 2)]))
        
        XCTAssertEqual(content.firstGroup(ofType: .card)?.id, "CARD")
    }
    
    // MARK: - Helpers
    
    typealias ProductTypeCounts = [(ProductType, Int)]

    private func makeGroups(
        productTypesCounts: ProductTypeCounts
    ) -> [ProductGroupView.ViewModel] {
        
        productTypesCounts.map { (productType, count) in

            let productsData: [ProductData] = makeProducts(count: count, ofType: productType)
            let products: [ProductView.ViewModel] = productsData.map(makeProductViewVM)
            
            return .init(
                productType: productType,
                products: products,
                dimensions: .regular,
                model: .emptyMock
            )
        }
    }
    
    // MARK: - Test Helpers
    
    func test_makeGroups_shouldReturnEmpty_onEmpty() {
        
        let counts: ProductTypeCounts = []
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            []
        )
    }
    
    func test_makeGroups_shouldReturnOneCardGroup_onCards() {
        
        let counts: ProductTypeCounts = [(.card, 5)]
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            ["CARD"]
        )
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.productType),
            [.card]
        )
    }
    
    func test_makeGroups_shouldReturnTwoGroup_onTwoTypes() {
        let counts: ProductTypeCounts = [(.card, 5), (.account, 9)]
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            ["CARD", "ACCOUNT"]
        )
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.productType),
            [.card, .account]
        )
    }
        
    func test_makeGroups_shouldPreserveOrder() {
        
        let counts: ProductTypeCounts = [(.account, 9), (.card, 5)]
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            ["ACCOUNT", "CARD"]
        )
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.productType),
            [.account, .card]
        )
    }
    
    #warning("add tests for products inside group")
}
