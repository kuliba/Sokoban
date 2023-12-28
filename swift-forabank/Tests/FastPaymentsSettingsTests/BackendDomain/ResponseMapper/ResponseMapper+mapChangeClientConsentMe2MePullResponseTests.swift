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
    
    func test_map_shouldDeliverServerErrorOnDataWithServerError() throws {
        
        let result = map(jsonWithServerError())
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOKHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
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
