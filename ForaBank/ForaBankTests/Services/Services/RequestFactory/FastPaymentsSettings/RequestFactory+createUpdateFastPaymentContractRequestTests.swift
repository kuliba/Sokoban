//
//  RequestFactory+createUpdateFastPaymentContractRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import RemoteServices
@testable import ForaBank
import XCTest

final class RequestFactory_createUpdateFastPaymentContractRequestTests: XCTestCase {
    
    func test_createUpdateFastPaymentContractRequest_shouldSetRequestURL() throws {
        
        let request = try createUpdateFastPaymentContractRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/updateFastPaymentContract"
        )
    }
    
    func test_createUpdateFastPaymentContractRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createUpdateFastPaymentContractRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createUpdateFastPaymentContractRequest_shouldSetRequestBody() throws {
        
        let payload = anyPayload(
            contractID: 123456789,
            selectableProductID: .account(98765432),
            flagBankDefault: .no,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .empty
        )
        let request = try createUpdateFastPaymentContractRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded, .init(
            contractId: 123456789,
            accountId: 98765432,
            flagBankDefault: "NO",
            flagClientAgreementIn: "YES",
            flagClientAgreementOut: "EMPTY"
        ))
    }
    
    func test_createUpdateFastPaymentContractRequest_shouldSetRequestBody_2() throws {
        
        let payload = anyPayload(
            contractID: 123456789,
            selectableProductID: .account(98765432),
            flagBankDefault: .yes,
            flagClientAgreementIn: .empty,
            flagClientAgreementOut: .no
        )
        let request = try createUpdateFastPaymentContractRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(decoded, .init(
            contractId: 123456789,
            accountId: 98765432,
            flagBankDefault: "YES",
            flagClientAgreementIn: "EMPTY",
            flagClientAgreementOut: "NO"
        ))
    }
    
    // MARK: - Helpers
    
    private func createUpdateFastPaymentContractRequest(
        _ payload: FastRequestFactory.UpdateFastPaymentContractPayload = anyPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createUpdateFastPaymentContractRequest(payload)
    }
    
    private struct _Payload: Decodable, Equatable {
        
        let contractId: Int
        let accountId: Int
        let flagBankDefault: String
        let flagClientAgreementIn: String
        let flagClientAgreementOut: String
    }
}

private typealias FastRequestFactory = RemoteServices.RequestFactory

private func anyPayload(
    contractID: Int = generateRandom11DigitNumber(),
    selectableProductID: SelectableProductID = .account(.init(generateRandom11DigitNumber())),
    flagBankDefault: FastRequestFactory.UpdateFastPaymentContractPayload.Flag = .empty,
    flagClientAgreementIn: FastRequestFactory.UpdateFastPaymentContractPayload.Flag = .empty,
    flagClientAgreementOut: FastRequestFactory.UpdateFastPaymentContractPayload.Flag = .empty
) -> FastRequestFactory.UpdateFastPaymentContractPayload {
    
    .init(
        contractID: contractID,
        selectableProductID: selectableProductID,
        flagBankDefault: flagBankDefault,
        flagClientAgreementIn: flagClientAgreementIn,
        flagClientAgreementOut: flagClientAgreementOut
    )
}
