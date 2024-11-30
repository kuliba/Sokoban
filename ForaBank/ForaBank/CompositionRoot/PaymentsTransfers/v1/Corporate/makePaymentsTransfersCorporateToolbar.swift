//
//  makePaymentsTransfersCorporateToolbar.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.11.2024.
//

import PayHub
import PayHubUI

extension PaymentsTransfersPersonalToolbarDomain.Binder: PaymentsTransfersCorporateToolbar {}

extension RootViewModelFactory {
    
    func makePaymentsTransfersCorporateToolbar(
        selection: PaymentsTransfersPersonalToolbarState.Selection? = nil
    ) -> PaymentsTransfersCorporateToolbar {
        
        makePaymentsTransfersPersonalToolbar(selection: selection)
    }
}
