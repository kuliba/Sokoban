//
//  PaymentsTransfersModel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

final class PaymentsTransfersModel<PayHub>: ObservableObject
where PayHub: Loadable {
    
    let payHub: PayHub
    
    init(
        payHub: PayHub
    ) {
        self.payHub = payHub
    }
}

extension PaymentsTransfersModel {
    
    func reload() {
        
        payHub.load()
    }
}
