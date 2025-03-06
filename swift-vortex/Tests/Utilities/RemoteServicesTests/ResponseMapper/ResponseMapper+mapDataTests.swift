//
//  ResponseMapper+mapDataTests.swift
//
//
//  Created by Igor Malyarov on 06.03.2025.
//

import RemoteServices
import XCTest

final class ResponseMapper_mapDataTests: XCTestCase {
    
    func test_map_shouldDeliverData_onEmptyData() {
        
        XCTAssertNoDiff(map(.empty), .success(.empty))
    }
    
    func test_map_shouldDeliverData_onEmptyJSON() {
        
        XCTAssertNoDiff(map(.emptyJSON), .success(.emptyJSON))
    }
    
    func test_map_shouldDeliverData_onEmptyDataResponse() {
        
        XCTAssertNoDiff(map(.emptyDataResponse), .success(.emptyDataResponse))
    }
    
    func test_map_shouldDeliverData_onNullServerResponse() {
        
        XCTAssertNoDiff(map(.nullServerResponse), .success(.nullServerResponse))
    }
    
    func test_map_shouldDeliverData_onServerError() {
        
        XCTAssertNoDiff(map(.serverError), .success(.serverError))
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.empty, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .empty))
            )
        }
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MappingResult<Data> {
        
        ResponseMapper.map(data, httpURLResponse)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
}
