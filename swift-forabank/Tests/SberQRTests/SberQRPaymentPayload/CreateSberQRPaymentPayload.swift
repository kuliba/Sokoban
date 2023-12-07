//
//  CreateSberQRPaymentPayload.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import Tagged

struct CreateSberQRPaymentPayload {
    
    let qrLink: URL
    let product: Product
    let amount: Amount?
}

extension CreateSberQRPaymentPayload {
    
    enum Product {
        
        case card(CardID)
        case account(AccountID)
        
        typealias CardID = Tagged<_CardID, Int>
        enum _CardID {}
        
        typealias AccountID = Tagged<_AccountID, Int>
        enum _AccountID {}
    }
    
    struct Amount {
        
        let amount: Decimal
        let currency: Currency
        
        typealias Currency = Tagged<_Currency, String>
        enum _Currency {}
    }
}
