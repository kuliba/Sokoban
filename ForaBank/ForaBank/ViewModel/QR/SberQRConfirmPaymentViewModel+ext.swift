//
//  SberQRConfirmPaymentViewModel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SberQR

extension SberQRConfirmPaymentViewModel {
    
    var navTitle: String {
        
        switch state {
        case let .editableAmount(editableAmount):
            return editableAmount.header.value
            
        case let .fixedAmount(fixedAmount):
            return fixedAmount.header.value
        }
    }
}
