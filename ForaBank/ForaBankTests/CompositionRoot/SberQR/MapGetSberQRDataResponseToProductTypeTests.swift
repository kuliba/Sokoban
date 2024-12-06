//
//  MapGetSberQRDataResponseToProductTypeTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class MapGetSberQRDataResponseToProductTypeTests: SberQRProductTests {
    
    func test_productTypes_shouldReturnEmptyOnEmptyParameters() {
        
        let emptyParameters: [Parameter] = []
        let response = makeGetSberQRDataResponse(with: emptyParameters)
        
        let productTypes = response.productTypes
        
        XCTAssert(productTypes.isEmpty)
        XCTAssert(emptyParameters.isEmpty)
    }
    
    func test_productTypes_shouldReturnEmptyOnNonEmptyParametersWithoutProductSelect() {
        
        let parametersWithoutProductSelect: [Parameter] = [
            amount(),
            header(),
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithoutProductSelect)
        
        let productTypes = response.productTypes
        
        XCTAssert(productTypes.isEmpty)
        XCTAssertFalse(parametersWithoutProductSelect.isEmpty)
        XCTAssertFalse(parametersWithoutProductSelect.hasProductSelect)
    }
    
    func test_productTypes_shouldReturnEmptyOnEmptyFilterProductTypes() {
        
        let filterProductTypes: [FilterProductType] = []
        let parametersWithProductSelect: [Parameter] = [
            amount(),
            header(),
            productSelect(productTypes: filterProductTypes, currencies: [])
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithProductSelect)
        
        let productTypes = response.productTypes
        
        XCTAssert(productTypes.isEmpty)
        XCTAssertFalse(parametersWithProductSelect.isEmpty)
        XCTAssert(parametersWithProductSelect.hasProductSelect)
    }
    
    func test_productTypes_shouldReturnProductTypes() {
        
        let filterProductTypes: [FilterProductType] = [.account, .card]
        let parametersWithProductSelect: [Parameter] = [
            amount(),
            header(),
            productSelect(productTypes: filterProductTypes, currencies: [])
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithProductSelect)
        
        let productTypes = response.productTypes
        
        XCTAssertNoDiff(productTypes, [.account, .card])
        XCTAssertFalse(parametersWithProductSelect.isEmpty)
        XCTAssert(parametersWithProductSelect.hasProductSelect)
    }
}
