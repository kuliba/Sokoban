//
//  ResponseMapper+mapFastPaymentContractFindListResponseTests.swift
//  
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias FastPaymentContractFindListResult = Result<Int, MappingError>
    
    static func mapFastPaymentContractFindListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> FastPaymentContractFindListResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapFastPaymentContractFindListResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.FastPaymentContractFindListResult {
        
        ResponseMapper.mapFastPaymentContractFindListResponse(data, httpURLResponse)
    }
}
