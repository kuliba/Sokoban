//
//  MapGetSberQRDataResponseToCurrenciesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class MapGetSberQRDataResponseToCurrenciesTests: SberQRProductTests {
    
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
            productSelect(productTypes: [], currencies: filterCurrencies)
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
            productSelect(productTypes: [], currencies: filterCurrencies)
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithProductSelect)
        
        let currencies = response.currencies
        
        XCTAssertNoDiff(currencies, ["RUB"])
        XCTAssertFalse(parametersWithProductSelect.isEmpty)
        XCTAssert(parametersWithProductSelect.hasProductSelect)
    }
}
