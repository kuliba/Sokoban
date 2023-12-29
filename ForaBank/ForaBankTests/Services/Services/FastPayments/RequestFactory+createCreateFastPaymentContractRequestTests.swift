//
//  RequestFactory+createCreateFastPaymentContractRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation

extension RequestFactory {
    
    struct CreateFastPaymentContractPayload: Equatable {
        
        let accountID: Int
        let flagBankDefault: Flag
        let flagClientAgreementIn: Flag
        let flagClientAgreementOut: Flag
        
        enum Flag: Equatable {
            
            case yes, no, empty
        }
    }
    
    static func createCreateFastPaymentContractRequest(
        url: URL,
        payload: CreateFastPaymentContractPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension RequestFactory.CreateFastPaymentContractPayload {
    
    var httpBody: Data {
        
        get throws {
        
            try JSONSerialization.data(withJSONObject: [
                "accountId" : accountID,
                "flagBankDefault" : flagBankDefault.rawValue,
                "flagClientAgreementIn" : flagClientAgreementIn.rawValue,
                "flagClientAgreementOut" : flagClientAgreementOut.rawValue
            ] as [String: Any])
        }
    }
}

private extension RequestFactory.CreateFastPaymentContractPayload.Flag {
    
    var rawValue: String {
        
        switch self {
        case .yes:   return "YES"
        case .no:    return "NO"
        case .empty: return "EMPTY"
        }
    }
}

@testable import ForaBank
import XCTest

final class RequestFactory_createCreateFastPaymentContractRequestTests: XCTestCase {
    
    func test_makeRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try makeRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_makeRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_makeRequest_shouldSetCachePolicy() throws {
        
        let request = try makeRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_makeRequest_shouldSetHTTPBody() throws {
        
        let payload = anyPayload()
        let request = try makeRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        try XCTAssertNoDiff(body.payload, payload)
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL = anyURL(string: "any-url"),
        payload: RequestFactory.CreateFastPaymentContractPayload = anyPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateFastPaymentContractRequest(
            url: url,
            payload: payload
        )
    }
    
    private struct Body: Decodable {
        
        let accountId: Int // 10004526647
        let flagBankDefault: String // "EMPTY"
        let flagClientAgreementIn: String // "YES"
        let flagClientAgreementOut: String // "YES"
        
        var payload: RequestFactory.CreateFastPaymentContractPayload {
            
            get throws {
                
                typealias Flag = RequestFactory.CreateFastPaymentContractPayload.Flag
                
                guard
                    let flagBankDefault = Flag(rawValue: flagBankDefault),
                    let flagClientAgreementIn = Flag(rawValue: flagClientAgreementIn),
                    let flagClientAgreementOut = Flag(rawValue: flagClientAgreementOut)
                else { throw MappingError() }
                
                return .init(
                    accountID: accountId,
                    flagBankDefault: flagBankDefault,
                    flagClientAgreementIn: flagClientAgreementIn,
                    flagClientAgreementOut: flagClientAgreementOut
                )
            }
        }
        
        struct MappingError: Error {}
    }
}

private typealias Flag = RequestFactory.CreateFastPaymentContractPayload.Flag

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
    accountID: Int = 10004526647,
    flagBankDefault: Flag = .empty,
    flagClientAgreementIn: Flag = .yes,
    flagClientAgreementOut: Flag = .yes
) -> RequestFactory.CreateFastPaymentContractPayload {
    
    .init(
        accountID: accountID,
        flagBankDefault: flagBankDefault,
        flagClientAgreementIn: flagClientAgreementIn,
        flagClientAgreementOut: flagClientAgreementOut
    )
}
