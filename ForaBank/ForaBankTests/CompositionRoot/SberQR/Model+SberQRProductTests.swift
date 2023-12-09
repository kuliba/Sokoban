//
//  Model+SberQRProductTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

extension Model {
    
    func sberQRProducts(
        productTypes: [ProductType] = ProductType.allCases
    ) -> [ProductSelect.Product.ID.RawValue] {
        
        allProducts
            .filter { productTypes.contains($0.productType) }
            .map(\.id)
    }
}

extension ProductData {
    
    var sberQRProduct: ProductSelect.Product? {
        
        if let card = self as? ProductCardData {
            
            return .init(
                id: .init(card.id),
                type: .card,
                icon: "",
                title: "",
                amountFormatted: "",
                color: ""
            )
        }
        
        if let account = self as? ProductAccountData {
            
            return .init(
                id: .init(account.id),
                type: .account,
                icon: "",
                title: "",
                amountFormatted: "",
                color: ""
            )
        }
        
        return nil
    }
}

final class Model_SberQRProductTests: XCTestCase {
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyProducts() {
        
        let sut = makeSUT()
        
        let products = sut.sberQRProducts()
        
        XCTAssert(products.isEmpty)
        XCTAssert(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyProductTypes() {
        
        let productTypes: [ProductType] = []
        let sut = makeSUT()
        
        let products = sut.sberQRProducts(productTypes: productTypes)
        
        XCTAssert(products.isEmpty)
        XCTAssert(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnMissingProductsOfSelectedProductType_card() {
        
        let productTypes: [ProductType] = [.card]
        let sut = makeSUT()
        sut.products.send(makeProductsData([(.account, 2)]))
        
        let products = sut.sberQRProducts(productTypes: productTypes)
        
        XCTAssert(products.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
        XCTAssert(sut.cards.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnMissingProductsOfSelectedProductType_account() {
        
        let productTypes: [ProductType] = [.account]
        let sut = makeSUT()
        sut.products.send(makeProductsData([(.card, 2)]))
        
        let products = sut.sberQRProducts(productTypes: productTypes)
        
        XCTAssert(products.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
        XCTAssert(sut.accounts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnProductsOfSelectedProductType() {
        
        let productTypes: [ProductType] = [.card]
        let sut = makeSUT()
        sut.products.send(makeProductsData([
            (.account, 2),
            (.card, 3)
        ]))
        
        let products = sut.sberQRProducts(productTypes: productTypes)
        
        XCTAssertNoDiff(products.count, 3)
        XCTAssertNoDiff(sut.allProducts.count, 5)
        XCTAssertNoDiff(sut.accounts.count, 2)
        XCTAssertNoDiff(sut.cards.count, 3)
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
    
    var cards: [ProductData] {
        
        allProducts.filter { $0.productType == .card }
    }
    
    var accounts: [ProductData] {
        
        allProducts.filter { $0.productType == .account }
    }
}
