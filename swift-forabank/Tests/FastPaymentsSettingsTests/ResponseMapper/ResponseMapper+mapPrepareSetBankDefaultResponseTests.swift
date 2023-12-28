//
//  ResponseMapper+mapPrepareSetBankDefaultResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias PrepareSetBankDefaultResult = Result<Int, MappingError>
    
    static func mapPrepareSetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> PrepareSetBankDefaultResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapPrepareSetBankDefaultResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.PrepareSetBankDefaultResult {
        
        ResponseMapper.mapPrepareSetBankDefaultResponse(data, httpURLResponse)
    }
}
