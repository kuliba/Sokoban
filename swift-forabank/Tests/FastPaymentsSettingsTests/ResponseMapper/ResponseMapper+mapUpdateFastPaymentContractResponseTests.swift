//
//  ResponseMapper+mapUpdateFastPaymentContractResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias UpdateFastPaymentContractResult = Result<Int, MappingError>
    
    static func mapUpdateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> UpdateFastPaymentContractResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapUpdateFastPaymentContractResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.UpdateFastPaymentContractResult {
        
        ResponseMapper.mapUpdateFastPaymentContractResponse(data, httpURLResponse)
    }
}
