//
//  ResponseMapper+mapGetOperationDetailByPaymentIDResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    static func mapGetOperationDetailByPaymentIDResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetOperationDetailByPaymentIDResponse? {
        
        try? map(data, httpURLResponse, mapOrThrow: GetOperationDetailByPaymentIDResponse.init).get()
    }
}

extension ResponseMapper {
    
    struct GetOperationDetailByPaymentIDResponse {}
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let a: Int
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init()
    }
}
    
import AnywayPayment
import RemoteServices
import XCTest

final class ResponseMapper_mapGetOperationDetailByPaymentIDResponseTests: XCTestCase {
    
    func test_map_shouldDeliverNilOnEmptyData() {
        
        XCTAssertNil(map(.empty))
    }
    
    func test_map_shouldDeliverNilOnInvalidData() {
        
        XCTAssertNil(map(.invalidData))
    }
    
    func test_map_shouldDeliverNilOnEmptyJSON() {
        
        XCTAssertNil(map(.emptyJSON))
    }
    
    func test_map_shouldDeliverNilOnEmptyDataResponse() {
        
        XCTAssertNil(map(.emptyDataResponse))
    }
    
    func test_map_shouldDeliverNilOnNullServerResponse() {
        
        XCTAssertNil(map(.nullServerResponse))
    }
    
    func test_map_shouldDeliverNilOnServerError() {
        
        XCTAssertNil(map(.serverError))
    }
    
    func test_map_shouldDeliverNilOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            XCTAssertNil(map(.validData, nonOkResponse))
        }
    }
    
    func test_map_shouldDeliverResponse() throws {
        
        try assert(.validData, .init(
        ))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.GetOperationDetailByPaymentIDResponse? {
        
        ResponseMapper.mapGetOperationDetailByPaymentIDResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: EquatableGetOperationDetailByPaymentIDResponseResponse,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try XCTUnwrap(map(data))
        XCTAssertNoDiff(.init(receivedResponse), response, file: file, line: line)
    }
}

private struct EquatableGetOperationDetailByPaymentIDResponseResponse: Equatable {
    
}

private extension EquatableGetOperationDetailByPaymentIDResponseResponse {
    
    init(_ response: ResponseMapper.GetOperationDetailByPaymentIDResponse) {
        
        self.init(
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
#warning("FIXME")
    static let validData: Data = String.validData.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
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
#warning("FIXME")
    static let validData = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "a": 1
    }
}
"""
}
