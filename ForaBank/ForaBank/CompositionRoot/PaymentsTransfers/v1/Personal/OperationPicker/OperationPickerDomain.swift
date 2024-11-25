//
//  OperationPickerDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import PayHubUI

typealias OperationPickerDomain = PayHubUI.OperationPickerDomain<CurrencyWalletViewModel, Latest, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>

final class LatestFlowStub {
    
    let latest: Latest
    
    init(latest: Latest) {
        
        self.latest = latest
    }
}

final class TemplatesStub {}

enum OperationPickerFlowStatus: Equatable {
    
    case main
    case exchangeFailure
}

