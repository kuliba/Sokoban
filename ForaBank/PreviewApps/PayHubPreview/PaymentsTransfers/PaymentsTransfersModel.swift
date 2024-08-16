//
//  PaymentsTransfersModel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

protocol Loadable {
    
    func load()
}

final class PaymentsTransfersModel<PayHub> 
where PayHub: Loadable {
    
    let payHub: PayHub
    
    init(
        payHub: PayHub
    ) {
        self.payHub = payHub
    }
}
