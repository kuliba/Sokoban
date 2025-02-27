//
//  ResponseMapper+mapGetSavingsAccountInfoRequestTests.swift
//
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import SavingsServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetSavingsAccountInfoRequestTests: XCTestCase {
    
    func test_map_shouldDeliverValidOnValidProducts() {
        
        XCTAssertNoDiff(
            map(.valid),
            .success(.valid))
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        XCTAssertNoDiff(
            map(.empty),
            .failure(.invalid(statusCode: 200, data: .empty))
        )
    }
    
    func test_map_shouldDeliverDefaultOnInvalidData() {
        
        XCTAssertNoDiff(
            map(.invalidData),
            .success(.empty)
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        XCTAssertNoDiff(
            map(.emptyJSON),
            .failure(.invalid(statusCode: 200, data: .emptyJSON))
        )
    }
    
    func test_map_shouldDeliverEmptyOnEmptyDataResponse() {
        
        XCTAssertNoDiff(
            map(.emptyDataResponse),
            .success(.empty)
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: .nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.valid, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .valid))
            )
        }
    }
        
    // MARK: - Helpers
    
    private typealias Response = GetSavingsAccountInfoResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetSavingsAccountInfoResponse(data, httpURLResponse)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let invalidData: Data = String.invalidData.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let valid: Data = String.valid.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "products": "junk" }
}
"""
    
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
    
    static let valid = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "dateNext": "2025-02-28",
        "interestAmount": 41311.0097,
        "interestPaid": 14.9400,
        "minRest": 2447811.4500
    }
}
"""
}

private extension GetSavingsAccountInfoResponse {
    
    static let valid: Self = .init(
        dateNext: "2025-02-28",
        interestAmount: 41311.0097,
        interestPaid: 14.9400,
        minRest: 2447811.4500
    )
    
    static let empty: Self = .init(dateNext: nil, interestAmount: nil, interestPaid: nil, minRest: nil)
}
