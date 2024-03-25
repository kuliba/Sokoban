//
//  RequestFactory+createUpdateFastPaymentContractRequest.swift
//  
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    struct UpdateFastPaymentContractPayload: Equatable {
        
        let contractID: Int
        let selectableProductID: SelectableProductID
        let flagBankDefault: Flag
        let flagClientAgreementIn: Flag
        let flagClientAgreementOut: Flag
        
        public init(
            contractID: Int, 
            selectableProductID: SelectableProductID,
            flagBankDefault: Flag,
            flagClientAgreementIn: Flag,
            flagClientAgreementOut: Flag
        ) {
            self.contractID = contractID
            self.selectableProductID = selectableProductID
            self.flagBankDefault = flagBankDefault
            self.flagClientAgreementIn = flagClientAgreementIn
            self.flagClientAgreementOut = flagClientAgreementOut
        }
        
        public enum Flag: Equatable {
            
            case yes, no, empty
        }
    }
    
    static func createUpdateFastPaymentContractRequest(
        url: URL,
        payload: UpdateFastPaymentContractPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension RequestFactory.UpdateFastPaymentContractPayload {
    
    var httpBody: Data {
        
        get throws {
            
            switch selectableProductID {
            case let .account(accountID):
                return try JSONSerialization.data(withJSONObject: [
                    "contractId" : contractID,
                    "accountId" : accountID.rawValue,
                    "flagBankDefault" : flagBankDefault.rawValue,
                    "flagClientAgreementIn" : flagClientAgreementIn.rawValue,
                    "flagClientAgreementOut" : flagClientAgreementOut.rawValue
                ] as [String: Any])
                
            case let .card(cardID):
                return try JSONSerialization.data(withJSONObject: [
                    "contractId" : contractID,
                    "cardId" : cardID.rawValue,
                    "flagBankDefault" : flagBankDefault.rawValue,
                    "flagClientAgreementIn" : flagClientAgreementIn.rawValue,
                    "flagClientAgreementOut" : flagClientAgreementOut.rawValue
                ] as [String: Any])
            }
        }
    }
}

private extension RequestFactory.UpdateFastPaymentContractPayload.Flag {
    
    var rawValue: String {
        
        switch self {
        case .yes:   return "YES"
        case .no:    return "NO"
        case .empty: return "EMPTY"
        }
    }
}
