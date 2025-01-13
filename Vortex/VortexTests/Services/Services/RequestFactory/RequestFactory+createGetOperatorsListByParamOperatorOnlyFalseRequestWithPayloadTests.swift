//
//  RequestFactory+createGetOperatorsListByParamOperatorOnlyFalseRequestWithPayloadTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

@testable import Vortex
import XCTest

final class RequestFactory_createGetOperatorsListByParamOperatorOnlyFalseRequestWithPayloadTests: XCTestCase {
    
    func test_createRequest_shouldThrowOnEmptyOperatorID() throws {
        
        try XCTAssertThrowsError(createRequest(makePayload(operatorID: "")))
    }
    
    func test_createRequest_shouldThrowOnEmptyType() throws {
        
        try XCTAssertThrowsError(createRequest(makePayload(type: "")))
    }
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest(makePayload())
        
        XCTAssertNoDiff(
            request.url?.lastPathComponent,
            "getOperatorsListByParam"
        )
    }
    
    func test_createRequest_shouldSetRequestURLWithoutSerial() throws {
        
        let payload = makePayload(serial: nil)
        let request = try createRequest(payload)
        
        try XCTAssertNoDiff(request.queryItems(), [
            .init(name: "operatorOnly", value: "false"),
            .init(name: "customerId", value: payload.operatorID),
            .init(name: "type", value: payload.type)
        ])
    }
    
    func test_createRequest_shouldSetRequestURLWithSerial() throws {
        
        let payload = makePayload()
        let request = try createRequest(payload)
        
        try XCTAssertNoDiff(request.queryItems(), [
            .init(name: "operatorOnly", value: "false"),
            .init(name: "customerId", value: payload.operatorID),
            .init(name: "type", value: payload.type),
            .init(name: "serial", value: payload.serial),
        ])
    }
    
    func test_createRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private typealias Payload = Vortex.RequestFactory.GetOperatorsListByParamOperatorOnlyFalsePayload
    
    private func createRequest(
        _ payload: Payload? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperatorsListByParamOperatorOnlyFalseRequest(
            payload: payload ?? makePayload()
        )
    }
    
    private func makePayload(
        operatorID: String = anyMessage(),
        type: String = anyMessage(),
        serial: String? = anyMessage()
    ) -> Payload {
        
        return .init(operatorID: operatorID, type: type, serial: serial)
    }
}

extension URLRequest {
    
    func queryItems() throws -> [URLQueryItem] {
        
        let url = try XCTUnwrap(url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        
        return try XCTUnwrap(components.queryItems)
    }
}
