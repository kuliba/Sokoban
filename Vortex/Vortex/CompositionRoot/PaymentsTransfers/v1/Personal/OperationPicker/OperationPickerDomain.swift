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
    
    case exchangeFailure
    case exchange(CurrencyWalletViewModel)
    case latest(LatestFlowStub)
    case outside(Outside)
    case templates
    
    enum Outside: Equatable {
        
        case main
    }
}

final class LatestFlowStub {
    
    let latest: Latest
    
    init(latest: Latest) {
        
        self.latest = latest
    }
}
