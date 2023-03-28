//
//  OptionSelectorViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.02.2023.
//

@testable import ForaBank
import XCTest

final class OptionSelectorViewModelTests: XCTestCase {
    
    // MARK: - Make Selector

    func test_makeSelector_shouldReturnNil_onEmptyProducts() {
        let sut = makeSUT(products: [])
        
        XCTAssertNil(sut)
    }
    
    func test_makeSelector_shouldReturnNil_onProductsOfSameType_accounts() {
        let accounts = makeProducts(count: 5, ofType: .account)
        let sut = makeSUT(products: accounts)
        
        XCTAssertNil(sut)
    }
    
    func test_makeSelector_shouldReturnNil_onProductsOfSameType_cards() {
        let cards = makeProducts(count: 5, ofType: .card)
        let sut = makeSUT(products: cards)
        
        XCTAssertNil(sut)
    }
    
    func test_makeSelector_shouldCreateSelector_onDifferentProductTypes() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products)
        
        XCTAssertNotNil(sut)
    }
    
    func test_makeSelector_shouldSelectCards() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products)
        
        XCTAssertEqual(sut?.selected, "CARD")
    }
    
    func test_makeSelector_shouldHaveCardsAndAccountsOptions() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products)
        
        XCTAssertEqual(sut?.options.map(\.title), ["Карты", "Счета"])
    }
    
    func test_makeSelector_shouldSetStyleToProducts_onProducts() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products, style: .products)
        
        XCTAssertEqual(sut?.style, .products)
    }
    
    func test_makeSelector_shouldSetStyleToProductsSmall_onProductsSmall() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products, style: .productsSmall)
        
        XCTAssertEqual(sut?.style, .productsSmall)
    }
    
    func test_makeSelector_shouldSetModeToAction() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products)
        
        XCTAssertEqual(sut?.mode, .action)
    }
    
    func test_makeSelector_shouldSetOptionStyleToProducts_onProducts() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products, style: .products)
        
        XCTAssertEqual(sut?.options.map(\.style), [.products, .products])
    }
    
    func test_makeSelector_shouldSetOptionStyleToProductsSmall_onProductsSmall() {
        let products = makeCardsAndAccounts()
        let sut = makeSUT(products: products, style: .productsSmall)
        
        XCTAssertEqual(sut?.options.map(\.style), [.productsSmall, .productsSmall])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        products: [ProductData],
        mode: ProductCarouselView.ViewModel.Mode = .main,
        style: OptionSelectorView.ViewModel.Style = .products,
        file: StaticString = #file,
        line: UInt = #line
    ) -> OptionSelectorView.ViewModel? {
        
        ProductCarouselView.ViewModel.makeSelector(
            products: products,
            mode: mode,
            style: style
        )
    }
    
    private func makeCardsAndAccounts() -> [ProductData] {
        let accounts = makeProducts(count: 5, ofType: .account)
        let cards = makeProducts(count: 9, ofType: .card)
        return accounts + cards
    }
}
