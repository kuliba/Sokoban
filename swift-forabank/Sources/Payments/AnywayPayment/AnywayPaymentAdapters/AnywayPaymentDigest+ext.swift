//
//  AnywayPaymentDigest+ext.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import AnywayPaymentDomain
import AnywayPaymentCore
import Foundation

public extension AnywayPaymentDigest {
    
    var json: Data {
        
        get throws { try JSONEncoder().encode(_dto) }
    }
}

private extension AnywayPaymentDigest {
    
    var _dto: _DTO {
        
        .init(
            amount: core?.amount,
            currencyAmount: core?.currency.rawValue,
            payer: core.map(\._payer),
            puref: puref.rawValue,
            additional: additional.map(\._additional)
        )
    }
    
    struct _DTO: Encodable {
        
        let amount: Decimal?
        let currencyAmount: String?
        let payer: Payer?
        let puref: String
        let additional: [Additional]
        
        struct Additional: Encodable {
            
            let fieldid: Int
            let fieldname: String
            let fieldvalue: String
        }
        
        struct Payer: Encodable {
            
            let cardId: Int?
            let accountId: Int?
        }
    }
}

private extension AnywayPaymentDigest.Additional {
    
    var _additional: AnywayPaymentDigest._DTO.Additional {
        
        .init(
            fieldid: fieldID,
            fieldname: fieldName,
            fieldvalue: fieldValue
        )
    }
}

private extension AnywayPaymentDigest.PaymentCore {
    
    var _payer: AnywayPaymentDigest._DTO.Payer {
        
        switch productID {
        case let .account(accountID):
            return .init(cardId: nil, accountId: accountID.rawValue)
            
        case let .card(cardID):
            return .init(cardId: cardID.rawValue, accountId: nil)
        }
    }
}
