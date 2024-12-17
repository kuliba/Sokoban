//
//  ServicesEndpointServiceNameBaseURLTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.08.2023.
//

@testable import ForaBank
import XCTest

final class ServicesEndpointServiceNameBaseURLTests: XCTestCase {
    
    /*
     активация сертификата
     https://pl.forabank.ru/dbo/api/v3/processing/registration/v1/getProcessingSessionCode
     https://dmz-api-gate-test.forabank.ru/processing/registration/v1/formSessionKey
     https://dmz-api-gate-test.forabank.ru/processing/registration/v1/bindPublicKeyWithEventId
     проверка сесионного ключа
     https://dmz-api-gate-test.forabank.ru/processing/authenticate/v1/processPublicKeyAuthenticationRequest
     просмотр cvv
     https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/showCVV
     смена пин
     https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/getPINConfirmationCode?sessionId=
     https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/changePIN
     */
    
    func test_baseURL_bindPublicKeyWithEventId() {
        
        // https://dmz-api-gate-test.forabank.ru/processing/registration/v1/bindPublicKeyWithEventId
        assertBaseURL(
            for: .bindPublicKeyWithEventId,
            is: "https://dmz-api-gate-test.forabank.ru"
        )
    }
    
    func test_baseURL_changePIN() {
        
        // https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/changePIN
        assertBaseURL(
            for: .changePIN,
            is: "https://dmz-api-gate-test.forabank.ru"
        )
    }
    
    func test_baseURL_formSessionKey() {
        
        // https://dmz-api-gate-test.forabank.ru/processing/registration/v1/formSessionKey
        assertBaseURL(
            for: .formSessionKey,
            is: "https://dmz-api-gate-test.forabank.ru"
        )
    }
    
    func test_baseURL_getPINConfirmationCode() {
        
        // https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/getPINConfirmationCode?sessionId=
        assertBaseURL(
            for: .getPINConfirmationCode,
            is: "https://dmz-api-gate-test.forabank.ru"
        )
    }
    
    func test_baseURL_getProcessingSessionCode() {
        
        // https://pl.forabank.ru/dbo/api/v3/processing/registration/v1/getProcessingSessionCode
        assertBaseURL(
            for: .getProcessingSessionCode,
            is: "https://pl.forabank.ru/dbo/api/v3"
        )
    }
    
    func test_baseURL_processPublicKeyAuthenticationRequest() {
        
        // https://dmz-api-gate-test.forabank.ru/processing/authenticate/v1/processPublicKeyAuthenticationRequest
        assertBaseURL(
            for: .processPublicKeyAuthenticationRequest,
            is: "https://dmz-api-gate-test.forabank.ru"
        )
    }
    
    func test_baseURL_showCVV() {
        
        // https://dmz-api-gate-test.forabank.ru/processing/cardInfo/v1/showCVV
        assertBaseURL(
            for: .showCVV,
            is: "https://dmz-api-gate-test.forabank.ru"
        )
    }
    
    // MARK: - Helpers
    
    private func assertBaseURL(
        for serviceName: Services.Endpoint.ServiceName,
        is string: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(serviceName.baseURL, string, file: file, line: line)
    }
}
