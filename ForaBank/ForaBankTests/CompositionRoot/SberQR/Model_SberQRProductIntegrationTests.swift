//
//  Model_SberQRProductIntegrationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class Model_SberQRProductIntegrationTests: XCTestCase {
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyAllProducts() {
        
        let filterProductTypes: [FilterProductType] = [.card]
        let currencies: [Currency] = [.rub]
        let response = makeGetSberQRDataResponse(with: [
            amount(),
            header(),
            productSelect(
                productTypes: filterProductTypes,
                currencies: currencies
            )
        ])
        let sut = makeSUT()
        
        let products = sut.sberQRProducts(response: response)
        
        XCTAssert(products.isEmpty)
        XCTAssert(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyProductType() {
        
        let filterProductTypes: [FilterProductType] = []
        let currencies: [Currency] = [.rub]
        let response = makeGetSberQRDataResponse(with: [
            amount(),
            header(),
            productSelect(
                productTypes: filterProductTypes,
                currencies: currencies
            )
        ])
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
        
        let products = sut.sberQRProducts(response: response)
        
        XCTAssert(products.isEmpty)
        XCTAssert(filterProductTypes.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnEmptyOnEmptyCurrencies() {
        
        let filterProductTypes: [FilterProductType] = [.card]
        let currencies: [Currency] = []
        let response = makeGetSberQRDataResponse(with: [
            amount(),
            header(),
            productSelect(
                productTypes: filterProductTypes,
                currencies: currencies
            )
        ])
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
        
        let products = sut.sberQRProducts(response: response)
        
        XCTAssert(products.isEmpty)
        XCTAssert(currencies.isEmpty)
        XCTAssertFalse(sut.allProducts.isEmpty)
    }
    
    func test_sberQRProducts_shouldReturnProductsOfSelectedProductType() {
        
        let filterProductTypes: [FilterProductType] = [.card]
        let currencies: [Currency] = [.rub]
        let response = makeGetSberQRDataResponse(with: [
            amount(),
            header(),
            productSelect(
                productTypes: filterProductTypes,
                currencies: currencies
            )
        ])
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
        
        let products = sut.sberQRProducts(response: response)
        
        XCTAssert(products.allSatisfy { $0.type == .card })
        XCTAssertNoDiff(sut.cards.map(\.id), [3, 4, 5])
        XCTAssertNoDiff(products.map(\.id), [3, 4, 5])
        XCTAssertNoDiff(products.count, 3)
        XCTAssertNoDiff(sut.allProducts.count, 5)
    }
    
    func test_sberQRProducts_shouldReturnProductsOfSelectedCurrency() {
        
        let filterProductTypes: [FilterProductType] = [.card]
        let currencies: [Currency] = [.rub]
        let response = makeGetSberQRDataResponse(with: [
            amount(),
            header(),
            productSelect(
                productTypes: filterProductTypes,
                currencies: currencies
            )
        ])
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
        
        let products = sut.sberQRProducts(response: response)
        
        XCTAssertNoDiff(products.map(\.id), [3, 5])
        XCTAssertNoDiff(products.count, 2)
        XCTAssertNoDiff(sut.allProducts.count, 5)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Model
    private typealias Parameter = GetSberQRDataResponse.Parameter
    private typealias FilterProductType = GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType
    private typealias Currency = GetSberQRDataResponse.Parameter.ProductSelect.Filter.Currency
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut: SUT = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeGetSberQRDataResponse(
        with parameters: [Parameter],
        required: [GetSberQRDataResponse.Required] = []
    ) -> GetSberQRDataResponse {
        
        .init(
            qrcID: UUID().uuidString,
            parameters: parameters,
            required: required
        )
    }
    
    private func amount() -> Parameter {
        
        .amount(.init(
            id: .paymentAmount,
            value: 123.45,
            title: "Title",
            validationRules: [],
            button: .init(
                title: "Pay",
                action: .paySberQR,
                color: .red
            )
        ))
    }
    
    private func header() -> Parameter {
        
        .header(.init(id: .title, value: "Title"))
    }
    
    private func productSelect(
        productTypes: [FilterProductType],
        currencies: [Currency]
    ) -> Parameter {
        
        .productSelect(.init(
            id: .init(UUID().uuidString),
            value: nil,
            title: "Title",
            filter: .init(
                productTypes: productTypes,
                currencies: currencies,
                additional: false
            )
        ))
    }
}
