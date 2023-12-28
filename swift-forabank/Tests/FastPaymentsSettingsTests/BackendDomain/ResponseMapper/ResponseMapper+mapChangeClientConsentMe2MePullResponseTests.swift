//
//  ResponseMapper+mapChangeClientConsentMe2MePullResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias ChangeClientConsentMe2MePullResult = Result<Int, MappingError>
    
    static func mapChangeClientConsentMe2MePullResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangeClientConsentMe2MePullResult {
        
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

final class ResponseMapper_mapChangeClientConsentMe2MePullResponseTests: XCTestCase {
    
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
    ) -> ResponseMapper.ChangeClientConsentMe2MePullResult {
        
        ResponseMapper.mapChangeClientConsentMe2MePullResponse(data, httpURLResponse)
    }
}
