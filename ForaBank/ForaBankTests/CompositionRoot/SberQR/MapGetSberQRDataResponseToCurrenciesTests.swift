//
//  MapGetSberQRDataResponseToCurrenciesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class MapGetSberQRDataResponseToCurrenciesTests: XCTestCase {
    
    func test_productTypes_shouldReturnEmptyOnEmptyParameters() {
        
        let emptyParameters: [Parameter] = []
        let response = makeGetSberQRDataResponse(with: emptyParameters)
        
        let currencies = response.currencies
        
        XCTAssert(currencies.isEmpty)
        XCTAssert(emptyParameters.isEmpty)
    }
    
    func test_productTypes_shouldReturnEmptyOnNonEmptyParametersWithoutProductSelect() {
        
        let parametersWithoutProductSelect: [Parameter] = [
            amount(),
            header(),
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithoutProductSelect)
        
        let currencies = response.currencies
        
        XCTAssert(currencies.isEmpty)
        XCTAssertFalse(parametersWithoutProductSelect.isEmpty)
        XCTAssertFalse(parametersWithoutProductSelect.hasProductSelect)
    }
    
    func test_productTypes_shouldReturnEmptyOnEmptyFilterProductTypes() {
        
        let filterCurrencies: [Currency] = []
        let parametersWithProductSelect: [Parameter] = [
            amount(),
            header(),
            productSelect(currencies: filterCurrencies)
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithProductSelect)
        
        let currencies = response.currencies
        
        XCTAssert(currencies.isEmpty)
        XCTAssertFalse(parametersWithProductSelect.isEmpty)
        XCTAssert(parametersWithProductSelect.hasProductSelect)
    }
    
    func test_productTypes_shouldReturn_____() {
        
        let filterCurrencies: [Currency] = [.rub]
        let parametersWithProductSelect: [Parameter] = [
            amount(),
            header(),
            productSelect(currencies: filterCurrencies)
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithProductSelect)
        
        let currencies = response.currencies
        
        XCTAssertNoDiff(currencies, ["RUB"])
        XCTAssertFalse(parametersWithProductSelect.isEmpty)
        XCTAssert(parametersWithProductSelect.hasProductSelect)
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = GetSberQRDataResponse.Parameter
    private typealias FilterProductType = GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType
    private typealias Currency = GetSberQRDataResponse.Parameter.ProductSelect.Filter.Currency
    
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
        currencies: [Currency]
    ) -> Parameter {
        
        .productSelect(.init(
            id: .init(UUID().uuidString),
            value: nil,
            title: "Title",
            filter: .init(
                productTypes: [],
                currencies: currencies,
                additional: false
            )
        ))
    }
}
