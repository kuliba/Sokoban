//
//  Model+SberQRProductTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import ProductSelectComponent
import SberQR
import XCTest

extension Model {
    
    func sberQRProducts(
        response: GetSberQRDataResponse,
        formatBalance: @escaping (ProductData) -> String
    ) -> [ProductSelect.Product] {
        
        allProducts.mapToSberQRProducts(
            response: response,
            formatBalance: formatBalance,
            getImage: { _ in .none }
        )
    }
    
    func sberQRProducts(
        productTypes: [ProductType],
        currencies: [String],
        formatBalance: @escaping (ProductData) -> String
    ) -> [ProductSelect.Product] {
        
        allProducts.mapToSberQRProducts(
            productTypes: productTypes,
            currencies: currencies, 
            formatBalance: formatBalance,
            getImage: { _ in .none }
        )
    }
}

final class Model_SberQRProductTests: SberQRProductTests {
    
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
        
        XCTAssertNil(loan.productSelectProduct { _ in "" } getImage: { _ in .none })
    }
    
    func test_sberQRProduct_shouldReturnCardFromCard() throws {
        
        let id = 1234
        let card = makeCardProduct(id: id)
        
        let product = try XCTUnwrap(card.productSelectProduct { _ in "" } getImage: { _ in .none })
        
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
        
            let product = try XCTUnwrap(card.productSelectProduct { _ in "" } getImage: { _ in .none })
        
        XCTAssertNoDiff(product.id, .init(id))
        XCTAssertNoDiff(product.type, .account)
        // TODO:
        //    XCTAssertNoDiff(product.icon, icon)
        //    XCTAssertNoDiff(product.title, title)
        //    XCTAssertNoDiff(product.amountFormatted, amountFormatted)
        //    XCTAssertNoDiff(product.color, color)
    }
}

private extension Model {
    
    func sberQRProducts(
        productTypes: [ProductType],
        currencies: [String]
    ) -> [ProductSelect.Product] {
        
        allProducts.mapToSberQRProducts(
            productTypes: productTypes,
            currencies: currencies,
            formatBalance: { _ in "" },
            getImage: { _ in .none }
        )
    }
}
