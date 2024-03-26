//
//  ResponseMapper+mapMakeTransferResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPayment
import RemoteServices
import XCTest

final class ResponseMapper_mapMakeTransferResponseTests: XCTestCase {
    
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
            XCTAssertNil(map(.validDataComplete, nonOkResponse))
        }
    }
    
    func test_map_shouldDeliverResponseComplete() throws {
        
        try assert(.validDataComplete, .init(
            operationDetailID: 18483,
            documentStatus: .complete
        ))
    }
    
    func test_map_shouldDeliverResponseInProgress() throws {
        
        try assert(.validDataInProgress, .init(
            operationDetailID: 18483,
            documentStatus: .inProgress
        ))
    }
    
    func test_map_shouldDeliverResponseRejected() throws {
        
        try assert(.validDataRejected, .init(
            operationDetailID: 18483,
            documentStatus: .rejected
        ))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MakeTransferResponse? {
        
        ResponseMapper.mapMakeTransferResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: EquatableMakeTransferResponse,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try XCTUnwrap(map(data))
        XCTAssertNoDiff(.init(receivedResponse), response, file: file, line: line)
    }
}

private struct EquatableMakeTransferResponse: Equatable {
    
    let operationDetailID: Int
    let documentStatus: EquatableDocumentStatus
}

private extension EquatableMakeTransferResponse {
    
    init(_ response: ResponseMapper.MakeTransferResponse) {
        
        self.init(
            operationDetailID: response.operationDetailID,
            documentStatus: .init(response.documentStatus)
        )
    }

    enum EquatableDocumentStatus: Equatable {
        
        case complete, inProgress, rejected
    }
}

private extension EquatableMakeTransferResponse.EquatableDocumentStatus {
    
    init(_ documentStatus: ResponseMapper.MakeTransferResponse.DocumentStatus) {
        
        switch documentStatus {
        case .complete:
            self = .complete
        case .inProgress:
            self = .inProgress
        case .rejected:
            self = .rejected
        }
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validDataComplete: Data = String.validDataComplete.json
    static let validDataInProgress: Data = String.validDataInProgress.json
    static let validDataRejected: Data = String.validDataRejected.json
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
    
    static let validDataComplete = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "paymentOperationDetailId": 18483,
        "documentStatus": "COMPLETE"
    }
}
"""
    
    static let validDataInProgress = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "paymentOperationDetailId": 18483,
        "documentStatus": "IN_PROGRESS"
    }
}
"""
    
    static let validDataRejected = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "paymentOperationDetailId": 18483,
        "documentStatus": "REJECTED"
    }
}
"""
}
