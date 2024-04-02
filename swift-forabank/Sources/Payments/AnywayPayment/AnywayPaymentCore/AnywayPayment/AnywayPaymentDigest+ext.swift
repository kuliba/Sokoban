//
//  AnywayPaymentDigest+ext.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import Foundation
#warning("adapter")
public extension AnywayPaymentDigest {
    
    var json: Data {
        
        get throws { try JSONEncoder().encode(_dto) }
    }
    
    private var _dto: _DTO {
        
        .init(
            check: check,
            amount: amount?.value,
            currencyAmount: amount?.currency.rawValue,
            payer: product.map {
                
                switch $0 {
                case let .account(accountID):
                    return .init(cardId: nil, accountId: accountID.rawValue)
                    
                case let .card(cardID):
                    return .init(cardId: cardID.rawValue, accountId: nil)
                }
            },
            comment: comment,
            puref: puref?.rawValue,
            additional: additionals.map {
                
                .init(
                    fieldid: $0.fieldID,
                    fieldname: $0.fieldName,
                    fieldvalue: $0.fieldValue
                )
            },
            mcc: mcc?.rawValue
        )
    }
    
    struct _DTO: Encodable {
        
        let check: Bool
        let amount: Decimal?
        let currencyAmount: String?
        let payer: Payer?
        let comment: String?
        let puref: String?
        let additional: [Additional]
        let mcc: String?
        
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
