//
//  Model+ProductsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.08.2024.
//

@testable import ForaBank
import XCTest

final class Model_ProductsTests: XCTestCase {
    
    // MARK: - test updateProducts

    func test_updateProducts_initialProductsIsEmpty_shouldUpdateProducts() {
        
        let sut = makeSUT()
        
        XCTAssertNoDiff(sut.products(.card), [])
        
        let result = sut.updateProducts(productsData: sut.products.value, with: .cardProducts, for: .card)
        
        XCTAssertNoDiff(result, [.card: .cardProducts])
        XCTAssertNoDiff(sut.products(.card), .cardProducts)
    }
    
    func test_updateProducts_initialProductsNotEmpty_shouldUpdateProducts() {
        
        let sut = makeSUT(productsData: [.card : [.cardActiveMainUsd]])
        
        XCTAssertNoDiff(sut.products(.card), [.cardActiveMainUsd])
        
        let result = sut.updateProducts(productsData: sut.products.value, with: [.cardActiveMainDebitOnlyRub], for: .card)
        
        XCTAssertNotNil(result[.card]?.contains(.cardActiveMainDebitOnlyRub))
        XCTAssertNotNil(result[.card]?.contains(.cardActiveMainUsd))

        XCTAssertNotNil(sut.products(.card)?.contains(.cardActiveMainDebitOnlyRub))
        XCTAssertNotNil(sut.products(.card)?.contains(.cardActiveMainUsd))
    }
    
    // MARK: - test handleGetProductListByTypeResponse

    func test_handleGetProductListByTypeResponse_cardType_responseNil_shouldNotUpdateProducts() {
        
        let sut = makeSUT(productsData: [.card : []])
        
        XCTAssertNoDiff(sut.products(.card), [])

        sut.handleGetProductListByTypeResponse(
            .card,
            .cardCommand,
            nil)
        
        XCTAssertNoDiff(sut.products(.card), [])
    }

    func test_handleGetProductListByTypeResponse_loanType_responseNil_shouldNotUpdateProducts() {
        
        let sut = makeSUT(productsData: [.loan : []])
        
        XCTAssertNoDiff(sut.products(.loan), [])

        sut.handleGetProductListByTypeResponse(
            .loan,
            .loanCommand,
            nil)
        
        XCTAssertNoDiff(sut.products(.loan), [])
    }
    
    func test_handleGetProductListByTypeResponse_depositType_responseNil_shouldNotUpdateProducts() {
        
        let sut = makeSUT(productsData: [.deposit : []])
        
        XCTAssertNoDiff(sut.products(.deposit), [])

        sut.handleGetProductListByTypeResponse(
            .deposit,
            .depositCommand,
            nil)
        
        XCTAssertNoDiff(sut.products(.deposit), [])
    }

    func test_handleGetProductListByTypeResponse_accountType_responseNil_shouldNotUpdateProducts() {
        
        let sut = makeSUT(productsData: [.account : []])
        
        XCTAssertNoDiff(sut.products(.account), [])

        sut.handleGetProductListByTypeResponse(
            .account,
            .accountCommand,
            nil)
        
        XCTAssertNoDiff(sut.products(.account), [])
    }

    func test_handleGetProductListByTypeResponse_cardType_responseNotNil_shouldUpdateProducts() {
        
        let sut = makeSUT(productsData: [.card : []])
        
        XCTAssertNoDiff(sut.products(.card), [])

        sut.handleGetProductListByTypeResponse(
            .card,
            .cardCommand,
            .init(serial: "", productList: [.cardActiveMainUsd]))
        
        XCTAssertNoDiff(sut.products(.card), [.cardActiveMainUsd])
    }

    func test_handleGetProductListByTypeResponse_loanType_responseNotNil_shouldUpdateProducts() {
        
        let sut = makeSUT(productsData: [.loan : []])
        
        XCTAssertNoDiff(sut.products(.loan), [])

        sut.handleGetProductListByTypeResponse(
            .loan,
            .loanCommand,
            .init(serial: "", productList: [.loanActiveRub]))
        
        XCTAssertNoDiff(sut.products(.loan), [.loanActiveRub])
    }
    
    func test_handleGetProductListByTypeResponse_depositType_responseNotNil_shouldUpdateProducts() {
        
        let sut = makeSUT(productsData: [.deposit : []])
        
        XCTAssertNoDiff(sut.products(.deposit), [])

        sut.handleGetProductListByTypeResponse(
            .deposit,
            .depositCommand,
            .init(serial: "", productList: [.depositActiveRub]))
        
        XCTAssertNoDiff(sut.products(.deposit), [.depositActiveRub])
    }

    func test_handleGetProductListByTypeResponse_accountType_responseNotNil_shouldUpdateProducts() {
        
        let sut = makeSUT(productsData: [.account : []])
        
        XCTAssertNoDiff(sut.products(.account), [])

        sut.handleGetProductListByTypeResponse(
            .account,
            .accountCommand,
            .init(serial: "", productList: [.accountActiveRub]))
        
        XCTAssertNoDiff(sut.products(.account), [.accountActiveRub])
    }

    // MARK: - Helpers
    
    private typealias SUT = Model

    private func makeSUT(
        productsData: ProductsData = [.card : []],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
                
        let sut = SUT.mockWithEmptyExcept()
        
        sut.products.value = productsData
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func handleResponseHelper(
        sut: SUT,
        productType: ProductType,
        response: Services.GetProductsResponse? = nil
    ) {
        sut.handleGetProductListByTypeResponse(
        productType,
        .init(token: "", productType: productType),
        response)
    }
}

private extension ServerCommands.ProductController.GetProductListByType {
    
    init(
        _ productType: ProductType
    ) {
        self.init(token: "", productType: productType)
    }
    
    static let accountCommand: Self = .init(.account)
    static let cardCommand: Self = .init(.card)
    static let depositCommand: Self = .init(.deposit)
    static let loanCommand: Self = .init(.loan)
}
