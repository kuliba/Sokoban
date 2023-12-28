//
//  ResponseMapper+mapGetBankDefaultResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias GetBankDefaultResult = Result<Int, MappingError>
    
    static func mapGetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetBankDefaultResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapGetBankDefaultResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.GetBankDefaultResult {
        
        ResponseMapper.mapGetBankDefaultResponse(data, httpURLResponse)
    }
}
