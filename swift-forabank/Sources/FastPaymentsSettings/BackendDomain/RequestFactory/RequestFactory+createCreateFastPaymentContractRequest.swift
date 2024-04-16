//
//  RequestFactory+createCreateFastPaymentContractRequest.swift
//  
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    struct CreateFastPaymentContractPayload: Equatable {
        
        let selectableProductID: SelectableProductID
        let flagBankDefault: Flag
        let flagClientAgreementIn: Flag
        let flagClientAgreementOut: Flag
        
        public init(
            selectableProductID: SelectableProductID,
            flagBankDefault: Flag,
            flagClientAgreementIn: Flag,
            flagClientAgreementOut: Flag
        ) {
            self.selectableProductID = selectableProductID
            self.flagBankDefault = flagBankDefault
            self.flagClientAgreementIn = flagClientAgreementIn
            self.flagClientAgreementOut = flagClientAgreementOut
        }
        
        public enum Flag: Equatable {
            
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
            
            switch selectableProductID {
            case let .account(accountID):
                return try JSONSerialization.data(withJSONObject: [
                    "accountId" : accountID.rawValue,
                    "flagBankDefault" : flagBankDefault.rawValue,
                    "flagClientAgreementIn" : flagClientAgreementIn.rawValue,
                    "flagClientAgreementOut" : flagClientAgreementOut.rawValue
                ] as [String: Any])
                
#warning("add tests for card case")
            case let .card(cardID):
                return try JSONSerialization.data(withJSONObject: [
                    "cardId" : cardID.rawValue,
                    "flagBankDefault" : flagBankDefault.rawValue,
                    "flagClientAgreementIn" : flagClientAgreementIn.rawValue,
                    "flagClientAgreementOut" : flagClientAgreementOut.rawValue
                ] as [String: Any])
            }
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
