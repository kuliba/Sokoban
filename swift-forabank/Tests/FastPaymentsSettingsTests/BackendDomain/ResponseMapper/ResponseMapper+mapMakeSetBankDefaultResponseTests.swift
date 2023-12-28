//
//  ResponseMapper+mapMakeSetBankDefaultResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias MakeSetBankDefaultResponseResult = Result<Int, MappingError>
    
    static func mapMakeSetBankDefaultResponseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeSetBankDefaultResponseResult {
        
        map(data, httpURLResponse, map: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> Int {
        
        throw anyError("unimplemented")
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapMakeSetBankDefaultResponseResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MakeSetBankDefaultResponseResult {
        
        ResponseMapper.mapMakeSetBankDefaultResponseResponse(data, httpURLResponse)
    }
}
