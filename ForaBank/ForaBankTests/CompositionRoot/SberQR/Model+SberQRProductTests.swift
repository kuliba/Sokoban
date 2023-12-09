//
//  Model+SberQRProductTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class Model_SberQRProductTests: XCTestCase {
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyAllProducts() {
        
        let sut = makeSUT()
        
        let products = sut.sberQRProducts(
            productTypes: ProductType.allCases,
            currencies: ["RUB"]
        )
        
        XCTAssert(products.isEmpty)
        XCTAssert(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyProductTypes() {
        
        let emptyProductTypes: [ProductType] = []
        let sut = makeSUT()
        
        let products = sut.sberQRProducts(
            productTypes: emptyProductTypes,
            currencies: ["RUB"]
        )
        
        XCTAssert(products.isEmpty)
        XCTAssert(emptyProductTypes.isEmpty)
        XCTAssert(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyCurrencies() {
        
        let emptyCurrencies: [String] = []
        let sut = makeSUT()
        
        let products = sut.sberQRProducts(
            productTypes: ProductType.allCases,
            currencies: emptyCurrencies
        )
        
        XCTAssert(products.isEmpty)
        XCTAssert(emptyCurrencies.isEmpty)
        XCTAssert(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnMissingProductsOfSelectedProductType_card() {
        
        let missingProductType: ProductType = .card
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [makeAccountProduct(id: 10)]
        ])
        
        let products = sut.sberQRProducts(
            productTypes: [missingProductType],
            currencies: ["RUB"]
        )
        
        XCTAssert(products.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
        XCTAssert(sut.cards.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnMissingProductsOfSelectedProductType_account() {
        
        let missingProductType: ProductType = .account
        let sut = makeSUT()
        sut.changeProducts(to: [
            .card: [
                makeCardProduct(id: 3),
                makeCardProduct(id: 4),
            ],
        ])
        
        let products = sut.sberQRProducts(
            productTypes: [missingProductType],
            currencies: ["RUB"]
        )
        
        XCTAssert(products.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
        XCTAssert(sut.accounts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnMissingProductsOfSelectedCurrency() {
        
        let missingCurrency = "RUB"
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1, currency: "USD"),
                makeAccountProduct(id: 2, currency: "USD"),
            ],
            .card: [
                makeCardProduct(id: 3, currency: "USD"),
                makeCardProduct(id: 4, currency: "USD"),
                makeCardProduct(id: 5, currency: "USD"),
            ],
        ])
        
        let products = sut.sberQRProducts(
            productTypes: ProductType.allCases,
            currencies: [missingCurrency]
        )
        
        XCTAssert(products.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
        XCTAssert(sut.allProducts.allSatisfy { $0.currency != missingCurrency })
    }
    
    func test_sberQRProducts_shouldReturnProductsOfSelectedProductType() {
        
        let productTypes: [ProductType] = [.card]
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1),
                makeAccountProduct(id: 2),
            ],
            .card: [
                makeCardProduct(id: 3),
                makeCardProduct(id: 4),
                makeCardProduct(id: 5),
            ],
        ])
        
        let products = sut.sberQRProducts(
            productTypes: productTypes,
            currencies: ["RUB"]
        )
        
        XCTAssert(products.allSatisfy { $0.type == .card })
        XCTAssertNoDiff(sut.cards.map(\.id), [3, 4, 5])
        XCTAssertNoDiff(products.map(\.id), [3, 4, 5])
        XCTAssertNoDiff(products.count, 3)
        XCTAssertNoDiff(sut.allProducts.count, 5)
    }
    
    func test_sberQRProducts_shouldReturnProductsOfSelectedCurrency() {
        
        let currency = "RUB"
        let sut = makeSUT()
        sut.changeProducts(to: [
            .account: [
                makeAccountProduct(id: 1, currency: "USD"),
                makeAccountProduct(id: 2, currency: "RUB"),
            ],
            .card: [
                makeCardProduct(id: 3, currency: "RUB"),
                makeCardProduct(id: 4, currency: "USD"),
                makeCardProduct(id: 5, currency: "RUB"),
            ],
        ])
        
        let products = sut.sberQRProducts(
            productTypes: ProductType.allCases,
            currencies: [currency]
        )
        
        XCTAssertNoDiff(products.map(\.id), [3, 5, 2], "Expect 3 products, accounts after cards.")
        XCTAssertNoDiff(products.count, 3)
        XCTAssertNoDiff(sut.allProducts.count, 5)
    }
    
    // MARK: - Mapping
    
    func test_sberQRProduct_shouldReturnNilFromLoan() throws {
        
        let loan = anyProduct(id: 1234, productType: .loan)
        
        XCTAssertNil(loan.sberQRProduct)
    }
    
    func test_sberQRProduct_shouldReturnCardFromCard() throws {
        
        let id = 1234
        let card = makeCardProduct(id: id)
        
        let product = try XCTUnwrap(card.sberQRProduct)
        
        XCTAssertNoDiff(product.id, .init(id))
        XCTAssertNoDiff(product.type, .card)
        // TODO:
        //    XCTAssertNoDiff(product.icon, icon)
        //    XCTAssertNoDiff(product.title, title)
        //    XCTAssertNoDiff(product.amountFormatted, amountFormatted)
        //    XCTAssertNoDiff(product.color, color)
    }
    
    func test_sberQRProduct_shouldReturnAccountFromAccount() throws {
        
        let id = 1234
        let card = makeAccountProduct(id: id)
        
        let product = try XCTUnwrap(card.sberQRProduct)
        
        XCTAssertNoDiff(product.id, .init(id))
        XCTAssertNoDiff(product.type, .account)
        // TODO:
        //    XCTAssertNoDiff(product.icon, icon)
        //    XCTAssertNoDiff(product.title, title)
        //    XCTAssertNoDiff(product.amountFormatted, amountFormatted)
        //    XCTAssertNoDiff(product.color, color)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Model
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut: SUT = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension Model {
    
    var cards: [ProductCardData] {
        
        allProducts
            .filter { $0.productType == .card }
            .compactMap { $0 as? ProductCardData }
    }
    
    var accounts: [ProductAccountData] {
        
        allProducts
            .filter { $0.productType == .account }
            .compactMap { $0 as? ProductAccountData }
    }
    
    func changeProducts(to products: ProductsData) {
        
        self.products.send(products)
    }
}
