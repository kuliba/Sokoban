//
//  MapGetSberQRDataResponseToProductTypeTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

extension GetSberQRDataResponse {
    
    var productTypes: [ProductType] {
        
        filterProductTypes.map(\.productType)
    }
}

private extension GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType {
    
    var productType: ProductType {
        
        switch self {
        case .account: return .account
        case .card:    return .card
        }
    }
}

final class MapGetSberQRDataResponseToProductTypeTests: XCTestCase {
    
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
            productSelect(productTypes: filterProductTypes)
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
            productSelect(productTypes: filterProductTypes)
        ]
        let response = makeGetSberQRDataResponse(with: parametersWithProductSelect)
        
        let productTypes = response.productTypes
        
        XCTAssertNoDiff(productTypes, [.account, .card])
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
        productTypes: [FilterProductType],
        currencies: [Currency] = []
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

private extension Array where Element == GetSberQRDataResponse.Parameter {
    
    var hasProductSelect: Bool {
        
        !allSatisfy {
            
            switch $0 {
            case .productSelect:
                return false
                
            default:
                return true
            }
        }
    }
}
