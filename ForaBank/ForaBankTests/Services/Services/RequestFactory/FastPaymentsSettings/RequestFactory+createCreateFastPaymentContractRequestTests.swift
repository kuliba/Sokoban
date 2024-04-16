//
//  RequestFactory+createCreateFastPaymentContractRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import RemoteServices
@testable import ForaBank
import XCTest

final class RequestFactory_createCreateFastPaymentContractRequestTests: XCTestCase {
    
    func test_createCreateFastPaymentContractRequest_shouldSetRequestURL() throws {
        
        let request = try createCreateFastPaymentContractRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/createFastPaymentContract"
        )
    }
    
    func test_createCreateFastPaymentContractRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createCreateFastPaymentContractRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createCreateFastPaymentContractRequest_shouldSetRequestBody() throws {
        
        let payload = anyPayload(
            selectableProductID: .account(98765432),
            flagBankDefault: .no,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .empty
        )
        let request = try createCreateFastPaymentContractRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded, .init(
            accountId: 98765432,
            flagBankDefault: "NO",
            flagClientAgreementIn: "YES",
            flagClientAgreementOut: "EMPTY"
        ))
    }
    
    func test_createCreateFastPaymentContractRequest_shouldSetRequestBody_2() throws {
        
        let payload = anyPayload(
            selectableProductID: .account(98765432),
            flagBankDefault: .yes,
            flagClientAgreementIn: .empty,
            flagClientAgreementOut: .no
        )
        let request = try createCreateFastPaymentContractRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded, .init(
            accountId: 98765432,
            flagBankDefault: "YES",
            flagClientAgreementIn: "EMPTY",
            flagClientAgreementOut: "NO"
        ))
    }
    
    // MARK: - Helpers
    
    private func createCreateFastPaymentContractRequest(
        _ payload: FastRequestFactory.CreateFastPaymentContractPayload = anyPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateFastPaymentContractRequest(payload)
    }
    
    private struct _Payload: Decodable, Equatable {
        
        let accountId: Int
        let flagBankDefault: String
        let flagClientAgreementIn: String
        let flagClientAgreementOut: String
    }
}

private typealias FastRequestFactory = RemoteServices.RequestFactory

private func anyPayload(
    selectableProductID: SelectableProductID = .account(.init(generateRandom11DigitNumber())),
    flagBankDefault: FastRequestFactory.CreateFastPaymentContractPayload.Flag = .empty,
    flagClientAgreementIn: FastRequestFactory.CreateFastPaymentContractPayload.Flag = .empty,
    flagClientAgreementOut: FastRequestFactory.CreateFastPaymentContractPayload.Flag = .empty
) -> FastRequestFactory.CreateFastPaymentContractPayload {
    
    .init(
        selectableProductID: selectableProductID,
        flagBankDefault: flagBankDefault,
        flagClientAgreementIn: flagClientAgreementIn,
        flagClientAgreementOut: flagClientAgreementOut
    )
}
