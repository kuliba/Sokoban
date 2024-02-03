//
//  RequestFactory+createGetBankDefaultRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
@testable import ForaBank
import XCTest

final class RequestFactory_createGetBankDefaultRequestTests: XCTestCase {
    
    func test_createGetBankDefaultRequest_shouldThrowOnEmptyPhoneNumber() throws {
        
        let emptyPhoneNumber = ""
        try XCTAssertThrowsError( createGetBankDefaultRequest(anyPhoneNumber(emptyPhoneNumber)))
    }
    
    func test_createGetBankDefaultRequest_shouldSetRequestURL() throws {
        
        let request = try createGetBankDefaultRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/getBankDefault"
        )
    }
    
    func test_createGetBankDefaultRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createGetBankDefaultRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createGetBankDefaultRequest_shouldSetRequestBodyToPhoneNumber() throws {
        
        let phoneNumber = "9876543"
        let request = try createGetBankDefaultRequest(anyPhoneNumber(phoneNumber))
        
        let decoded = try JSONDecoder().decode(_PhoneNumber.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded.phoneNumber, phoneNumber)
    }
    
    // MARK: - Helpers
    
    private func createGetBankDefaultRequest(
        _ payload: FastPaymentsSettings.PhoneNumber = anyPhoneNumber()
    ) throws -> URLRequest {
        
        try RequestFactory.createGetBankDefaultRequest(payload)
    }
    
    private struct _PhoneNumber: Decodable {
        
        let phoneNumber: String
    }
}

private func anyPhoneNumber(
    _ rawValue: String = UUID().uuidString
) -> FastPaymentsSettings.PhoneNumber {
    
    .init(rawValue)
}
