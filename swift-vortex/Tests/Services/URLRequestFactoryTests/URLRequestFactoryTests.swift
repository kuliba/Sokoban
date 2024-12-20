//
//  URLRequestFactoryTests.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import URLRequestFactory
import XCTest

final class URLRequestFactoryTests: XCTestCase {
    
    func test_makeRequest_shouldSetRequestURLToGiven() throws {
        
        let url = anyURL()
        let sut = makeSUT(url: url)
        let services: [SUT.Service] = [
            .bindPublicKeyWithEventID(makeBindPublicKeyWithEventIDPayload()),
            .changePIN(makeChangePINPayload()),
            .formSessionKey(makeFormSessionKeyPayload()),
            .getPINConfirmationCode(anySessionID()),
            .getProcessingSessionCode,
            .processPublicKeyAuthenticationRequest(anyData()),
            .showCVV(makeShowCVVPayload())
        ]
        
        for service in services {
            
            let request = try sut.makeRequest(for: service)
            
            XCTAssertNoDiff(request.url, url, "\nExpected \"\(url)\" url for \"\(service)\" service, but got \"\(String(describing: request.url))\".")
        }
    }
    
    // MARK: - HTTPMethod
    
    func test_makeRequest_shouldSetHTTPMethodToPOST_bindPublicKeyWithEventIDService() throws {
        
        let service: SUT.Service = .bindPublicKeyWithEventID(makeBindPublicKeyWithEventIDPayload())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST_changePINService() throws {
        
        let service: SUT.Service = .changePIN(makeChangePINPayload())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST_formSessionKeyService() throws {
        
        let service: SUT.Service = .formSessionKey(makeFormSessionKeyPayload())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetHTTPMethodToGET_getPINConfirmationCodeService() throws {
        
        let service: SUT.Service = .getPINConfirmationCode(anySessionID())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST_getProcessingSessionCodeService() throws {
        
        let service: SUT.Service = .getProcessingSessionCode
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "GET")
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST_processPublicKeyAuthenticationRequestService() throws {
        
        let service: SUT.Service = .processPublicKeyAuthenticationRequest(anyData())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST_showCVVService() throws {
        
        let service: SUT.Service = .showCVV(makeShowCVVPayload())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    // MARK: - HTTPBody bindPublicKeyWithEventID
    
    func test_httpBody_bindPublicKeyWithEventID_shouldThrowOnEmptyEventID() throws {
        
        let payload = makeBindPublicKeyWithEventIDPayload(
            eventIDValue: ""
        )
        let service: SUT.Service = .bindPublicKeyWithEventID(payload)
        
        try assertMakeRequest(for: service, delivers: .bindPublicKeyWithEventIDEmptyEventID)
    }
    
    func test_httpBody_bindPublicKeyWithEventID_shouldThrowOnEmptyKey() throws {
        
        let payload = makeBindPublicKeyWithEventIDPayload(
            keyValue: .empty
        )
        let service: SUT.Service = .bindPublicKeyWithEventID(payload)
        
        try assertMakeRequest(for: service, delivers: .bindPublicKeyWithEventIDEmptyKey)
    }
    
    func test_makeRequest_shouldSetHTTPBody_bindPublicKeyWithEventIDService() throws {
        
        let payload = makeBindPublicKeyWithEventIDPayload()
        let service: SUT.Service = .bindPublicKeyWithEventID(payload)
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedBody = try JSONDecoder().decode(
            BindPublicKeyWithEventID.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedBody.eventId, payload.eventID.value)
        XCTAssertNoDiff(decodedBody.dataAsData, payload.key.value)
    }
    
    // MARK: - HTTPBody changePIN
    
    func test_httpBody_changePIN_shouldThrowOnEmptySessionID() throws {
        
        let payload = makeChangePINPayload(
            sessionIDValue: ""
        )
        let service: SUT.Service = .changePIN(payload)
        
        try assertMakeRequest(for: service, delivers: .emptySessionID)
    }
    
    func test_httpBody_changePIN_shouldThrowOnEmptyData() throws {
        
        let payload = makeChangePINPayload(
            data: .empty
        )
        let service: SUT.Service = .changePIN(payload)
        
        try assertMakeRequest(for: service, delivers: .emptyData)
    }
    
    func test_makeRequest_shouldSetHTTPBody_changePINService() throws {
        
        let payload = makeChangePINPayload()
        let service: SUT.Service = .changePIN(payload)
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedBody = try JSONDecoder().decode(
            ChangePIN.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedBody.sessionId, payload.sessionID.value)
        XCTAssertNoDiff(decodedBody.dataAsData, payload.data)
    }
    
    // MARK: - HTTPBody formSessionKey
    
    func test_httpBody_formSessionKey_shouldThrowOnEmptyCode() throws {
        
        let payload = makeFormSessionKeyPayload(
            codeValue: ""
        )
        let service: SUT.Service = .formSessionKey(payload)
        
        try assertMakeRequest(for: service, delivers: .formSessionKeyEmptyCode)
    }
    
    func test_httpBody_formSessionKey_shouldThrowOnEmptyData() throws {
        
        let payload = makeFormSessionKeyPayload(
            data: .empty
        )
        let service: SUT.Service = .formSessionKey(payload)
        
        try assertMakeRequest(for: service, delivers: .formSessionKeyEmptyData)
    }
    
    func test_makeRequest_shouldSetHTTPBody_formSessionKeyService() throws {
        
        let payload = makeFormSessionKeyPayload()
        let service: SUT.Service = .formSessionKey(payload)
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedBody = try JSONDecoder().decode(
            FormSessionKey.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedBody.code, payload.code.value)
        XCTAssertNoDiff(decodedBody.dataAsData, payload.data)
    }
    
    // MARK: - HTTPBody getPINConfirmationCode
    
    func test_httpBody_getPINConfirmationCode_shouldThrowOnEmptySessionID() throws {
        
        let payload = anySessionID("")
        let service: SUT.Service = .getPINConfirmationCode(payload)
        
        try assertMakeRequest(for: service, delivers: .emptySessionID)
    }
    
    func test_makeRequest_shouldSetHTTPBodyToNil_getPINConfirmationCodeService() throws {
        
        let service: SUT.Service = .getPINConfirmationCode(anySessionID())
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - HTTPBody getProcessingSessionCode
    
    func test_makeRequest_shouldSetHTTPBodyToNil_getProcessingSessionCodeService() throws {
        
        let service: SUT.Service = .getProcessingSessionCode
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - HTTPBody processPublicKeyAuthenticationRequest
    
    func test_makeRequest_shouldThrowOnEmptyData() throws {
        
        let payload: Data = .empty
        let service: SUT.Service = .processPublicKeyAuthenticationRequest(payload)
        
        try assertMakeRequest(for: service, delivers: .emptyData)
    }
        
    func test_makeRequest_shouldSetHTTPBody_processPublicKeyAuthenticationRequestService() throws {
        
        let data = anyData()
        let service: SUT.Service = .processPublicKeyAuthenticationRequest(data)
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        XCTAssertNoDiff(request.httpBody, data)
    }
    
    // MARK: - HTTPBody showCVV
    
    func test_httpBody_showCVV_shouldThrowOnEmptySessionID() throws {
        
        let payload = makeShowCVVPayload(
            sessionIDValue: ""
        )
        let service: SUT.Service = .showCVV(payload)
        
        try assertMakeRequest(for: service, delivers: .emptySessionID)
    }
    
    func test_httpBody_showCVV_shouldThrowOnEmptyData() throws {
        
        let payload = makeShowCVVPayload(
            data: .empty
        )
        let service: SUT.Service = .showCVV(payload)
        
        try assertMakeRequest(for: service, delivers: .emptyData)
    }
    
    func test_makeRequest_shouldSetHTTPBody_showCVVService() throws {
        
        let payload = makeShowCVVPayload()
        let service: SUT.Service = .showCVV(payload)
        let sut = makeSUT()
        
        let request = try sut.makeRequest(for: service)
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedBody = try JSONDecoder().decode(
            ShowCVV.self,
            from: httpBody
        )
        
        XCTAssertNoDiff(decodedBody.sessionId, payload.sessionID.value)
        XCTAssertNoDiff(decodedBody.dataAsData, payload.data)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = URLRequestFactory
    private typealias Service = URLRequestFactory.Service
    private typealias ServiceError = Service.Error
    
    private func makeSUT(
        url: URL = anyURL(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(url: url)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertMakeRequest(
        url: URL = anyURL(),
        for service: Service,
        delivers error: ServiceError,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let sut = makeSUT(url: url, file: file, line: line)
        
        try XCTAssertThrowsAsNSError(
            sut.makeRequest(for: service),
            file: file, line: line,
            error: error
        )
    }
    
    // MARK: - bindPublicKeyWithEventID
    
    private func makeBindPublicKeyWithEventIDPayload(
        eventIDValue: String = UUID().uuidString,
        keyValue: Data = anyData()
    ) -> URLRequestFactory.Service.BindPublicKeyWithEventIDPayload {
        
        .init(
            eventID: .init(value: eventIDValue),
            key: .init(value: keyValue)
        )
    }
    
    private struct BindPublicKeyWithEventID: Decodable {
        
        let eventId: String
        let data: String
        
        var dataAsData: Data? {
            
            .init(base64Encoded: data)
        }
    }
    
    // MARK: - changePIN
    
    private func makeChangePINPayload(
        sessionIDValue: String = UUID().uuidString,
        data: Data = anyData()
    ) -> URLRequestFactory.Service.ChangePINPayload {
        
        .init(
            sessionID: .init(value: sessionIDValue),
            data: data
        )
    }
    
    private struct ChangePIN: Decodable {
        
        let sessionId: String
        let data: String
        
        var dataAsData: Data? {
            
            .init(base64Encoded: data)
        }
    }
    
    // MARK: - formSessionKey
    
    private func makeFormSessionKeyPayload(
        codeValue: String = UUID().uuidString,
        data: Data = anyData()
    ) -> URLRequestFactory.Service.FormSessionKeyPayload {
        
        .init(
            code: .init(value: codeValue),
            data: data
        )
    }
    
    private struct FormSessionKey: Decodable {
        
        let code: String
        let data: String
        
        var dataAsData: Data? {
            
            .init(base64Encoded: data)
        }
    }
    
    // MARK: - showCVV
    
    private func makeShowCVVPayload(
        sessionIDValue: String = UUID().uuidString,
        data: Data = anyData()
    ) -> URLRequestFactory.Service.ShowCVVPayload {
        
        .init(
            sessionID: .init(value: sessionIDValue),
            data: data
        )
    }
    
    private typealias ShowCVV = ChangePIN
}

private func anyURL(
    _ string: String = UUID().uuidString
) -> URL {
    
    .init(string: string)!
}

private func anySessionID(
    _ value: String = UUID().uuidString
) -> URLRequestFactory.Service.SessionIDWithDataPayload.SessionID {
    
    .init(value: value)
}
