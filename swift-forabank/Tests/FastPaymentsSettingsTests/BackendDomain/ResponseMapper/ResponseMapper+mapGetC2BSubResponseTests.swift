//
//  ResponseMapper+mapGetC2BSubResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias GetC2BSubResponseResult = Result<Int, MappingError>
    
    static func mapGetC2BSubResponseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetC2BSubResponseResult {
        
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

final class ResponseMapper_mapGetC2BSubResponseResponseTests: XCTestCase {
    
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
    ) -> ResponseMapper.GetC2BSubResponseResult {
        
        ResponseMapper.mapGetC2BSubResponseResponse(data, httpURLResponse)
    }
}
