//
//  OperationPickerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import PayHubUI

typealias OperationPickerDomain = PayHubUI.OperationPickerDomain<Latest, OperationPickerNavigation>

extension OperationPickerDomain {
    
    typealias Navigation = OperationPickerNavigation
}

enum OperationPickerNavigation {
    
    case exchange(CurrencyWalletViewModel)
    case exchangeFailure
    case latest(PaymentsDomain.Navigation)
    case outside(Outside)
    case templates
    
    enum Outside: Equatable {
        
        case main
    }
}
