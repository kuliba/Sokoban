//
//  ResponseMapper+mapMakeSetBankDefaultResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias MakeSetBankDefaultResult = Result<Int, MappingError>
    
    static func mapMakeSetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeSetBankDefaultResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapMakeSetBankDefaultResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.MakeSetBankDefaultResult {
        
        ResponseMapper.mapMakeSetBankDefaultResponse(data, httpURLResponse)
    }
}
