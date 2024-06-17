//
//  ResponseMapper+mapGetVerificationCodeResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPaymentBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapGetVerificationCodeResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
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
                map(.validDataNoOTP, nonOkResponse),
                .failure(.invalid(
                    statusCode: statusCode,
                    data: .validDataNoOTP
                ))
            )
        }
    }
    
    func test_map_shouldDeliverResponseWithoutOTP() throws {
        
        try assert(.validDataNoOTP, .init(
            resendOTPCount: 3,
            otp: nil
        ))
    }
    
    func test_map_shouldDeliverResponseWithOTP() throws {
        
        try assert(.validDataWithOTP, .init(
            resendOTPCount: 4,
            otp: "654321"
        ))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetVerificationCodeResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetVerificationCodeResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try map(data).get()
        XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validDataNoOTP: Data = String.validDataNoOTP.json
    static let validDataWithOTP: Data = String.validDataWithOTP.json
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
    
    static let validDataNoOTP = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "resendOTPCount": 3,
        "otp": null
    }
}
"""
    
    static let validDataWithOTP = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "resendOTPCount": 4,
        "otp": "654321"
    }
}
"""
}
