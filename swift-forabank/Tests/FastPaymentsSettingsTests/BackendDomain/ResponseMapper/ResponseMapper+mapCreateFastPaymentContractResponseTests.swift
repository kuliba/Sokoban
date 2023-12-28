//
//  ResponseMapper+mapCreateFastPaymentContractResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias CreateFastPaymentContractResult = Result<Int, MappingError>
    
    static func mapCreateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> CreateFastPaymentContractResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapCreateFastPaymentContractResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.CreateFastPaymentContractResult {
        
        ResponseMapper.mapCreateFastPaymentContractResponse(data, httpURLResponse)
    }
}
