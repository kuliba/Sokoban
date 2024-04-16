//
//  RequestFactory+createUpdateFastPaymentContractRequestTests.swift
//
//
//  Created by Igor Malyarov on 29.12.2023.
//

import FastPaymentsSettings
import RemoteServices
import XCTest

final class RequestFactory_createUpdateFastPaymentContractRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetHTTPBody() throws {
        
        let payload = anyPayload()
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        try XCTAssertNoDiff(body.payload, payload)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: RequestFactory.UpdateFastPaymentContractPayload = anyPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createUpdateFastPaymentContractRequest(
            url: url,
            payload: payload
        )
    }
    
    private struct Body: Decodable {
        
        let contractId: Int // 10000084818
        let accountId: Int // 10004203497
        let flagBankDefault: String // "EMPTY"
        let flagClientAgreementIn: String // "YES"
        let flagClientAgreementOut: String // "YES"
        
        var payload: RequestFactory.UpdateFastPaymentContractPayload {
            
            get throws {
                
                typealias Flag = RequestFactory.UpdateFastPaymentContractPayload.Flag
                
                guard
                    let flagBankDefault = Flag(rawValue: flagBankDefault),
                    let flagClientAgreementIn = Flag(rawValue: flagClientAgreementIn),
                    let flagClientAgreementOut = Flag(rawValue: flagClientAgreementOut)
                else { throw MappingError() }
                
                return .init(
                    contractID: contractId,
                    selectableProductID: .account(.init(accountId)),
                    flagBankDefault: flagBankDefault,
                    flagClientAgreementIn: flagClientAgreementIn,
                    flagClientAgreementOut: flagClientAgreementOut
                )
            }
        }
        
        struct MappingError: Error {}
    }
}

private typealias Flag = RequestFactory.UpdateFastPaymentContractPayload.Flag

private extension Flag {
    
    init?(rawValue: String) {
        
        switch rawValue {
        case "YES":   self = .yes
        case "NO":    self = .no
        case "EMPTY": self = .empty
        default:      return nil
        }
    }
}

private func anyPayload(
    contractID: Int = 10000084818,
    selectableProductID: SelectableProductID = .account(10004203497),
    flagBankDefault: Flag = .empty,
    flagClientAgreementIn: Flag = .yes,
    flagClientAgreementOut: Flag = .yes
) -> RequestFactory.UpdateFastPaymentContractPayload {
    
    .init(
        contractID: contractID,
        selectableProductID: selectableProductID,
        flagBankDefault: flagBankDefault,
        flagClientAgreementIn: flagClientAgreementIn,
        flagClientAgreementOut: flagClientAgreementOut
    )
}
