//
//  ResponseMapper+mapCreateC2GPaymentResponseTests.swift.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapCreateC2GPaymentResponseTests_swift: XCTestCase {
    
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
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() throws {
        
        let data: Data = .validData
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(data, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: data))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_shouldDeliverResponse_onValidDataComplete() throws {
        
        let validData: Data = .validDataComplete
        
        XCTAssertNoDiff(
            map(validData),
            .success(
                makeResponse(
                    amount: 600.2,
                    documentStatus: "COMPLETE",
                    merchantName: "ГУОБДД МВД России",
                    paymentOperationDetailID: 119389,
                    purpose: "Штраф ГИБДД 600,2р ВУ"
                )
            )
        )
    }
    
    func test_shouldDeliverResponse_onValidDataRejected() throws {
        
        let validData: Data = .validDataRejected
        
        XCTAssertNoDiff(
            map(validData),
            .success(
                makeResponse(
                    amount: 600.2,
                    documentStatus: "REJECTED",
                    merchantName: "ГУОБДД МВД России",
                    paymentOperationDetailID: 119389,
                    purpose: "Штраф ГИБДД 600,2р ВУ"
                )
            )
        )
    }
    
    func test_shouldDeliverResponse_onValidDataInProgress() throws {
        
        let validData: Data = .validDataInProgress
        
        XCTAssertNoDiff(
            map(validData),
            .success(
                makeResponse(
                    amount: 600.2,
                    documentStatus: "IN_PROGRESS",
                    merchantName: "ГУОБДД МВД России",
                    paymentOperationDetailID: 119389,
                    purpose: "Штраф ГИБДД 600,2р ВУ"
                )
            )
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.CreateC2GPaymentResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapCreateC2GPaymentResponse(data, httpURLResponse)
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
    
    private func makeResponse(
        amount: Decimal? = nil,
        documentStatus: String,
        merchantName: String? = nil,
        message: String? = nil,
        paymentOperationDetailID: Int,
        purpose: String? = nil
    ) -> ResponseMapper.CreateC2GPaymentResponse {
        
        return .init(
            amount: amount,
            documentStatus: documentStatus,
            merchantName: merchantName,
            message: message,
            paymentOperationDetailID: paymentOperationDetailID,
            purpose: purpose
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyJSON: Data = String.emptyJSON.json
    static let invalidData: Data = String.invalidData.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    
    static let validData: Data = validDataComplete
    static let validDataComplete: Data = String.validDataComplete.json
    static let validDataRejected: Data = String.validDataRejected.json
    static let validDataInProgress: Data = String.validDataInProgress.json
}

private extension String {
    
    var json: Data { .init(utf8) }
    
    static let emptyJSON = "{}"
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
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
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": []
}
"""
    
    static let validDataComplete = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "paymentOperationDetailId": 119389,
    "documentStatus": "COMPLETE",
    "amount": 600.2,
    "merchantName": "ГУОБДД МВД России",
    "purpose": "Штраф ГИБДД 600,2р ВУ"
  }
}
"""
    
    static let validDataRejected = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "paymentOperationDetailId": 119389,
    "documentStatus": "REJECTED",
    "amount": 600.2,
    "merchantName": "ГУОБДД МВД России",
    "purpose": "Штраф ГИБДД 600,2р ВУ"
  }
}
"""
    
    static let validDataInProgress = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "paymentOperationDetailId": 119389,
    "documentStatus": "IN_PROGRESS",
    "amount": 600.2,
    "merchantName": "ГУОБДД МВД России",
    "purpose": "Штраф ГИБДД 600,2р ВУ"
  }
}
"""
}
