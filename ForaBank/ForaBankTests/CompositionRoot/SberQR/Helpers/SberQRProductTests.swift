//
//  SberQRProductTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import Vortex
import SberQR
import XCTest

class SberQRProductTests: XCTestCase {
    
    // MARK: - Helpers
    
    typealias SUT = Model
    typealias Parameter = GetSberQRDataResponse.Parameter
    typealias FilterProductType = GetSberQRDataResponse.Parameter.ProductSelect.Filter.ProductType
    typealias Currency = GetSberQRDataResponse.Parameter.ProductSelect.Filter.Currency
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut: SUT = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func makeGetSberQRDataResponse(
        with parameters: [Parameter],
        required: [GetSberQRDataResponse.Required] = []
    ) -> GetSberQRDataResponse {
        
        .init(
            qrcID: UUID().uuidString,
            parameters: parameters,
            required: required
        )
    }
    
    func amount() -> Parameter {
        
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
    
    func header() -> Parameter {
        
        .header(.init(id: .title, value: "Title"))
    }
    
    func productSelect(
        productTypes: [FilterProductType],
        currencies: [Currency]
    ) -> Parameter {
        
        .productSelect(.init(
            id: .debit_account,
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
