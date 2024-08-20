//
//  PaymentsTransfersModel.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

final class PaymentsTransfersModel<PayHubPicker>: ObservableObject
where PayHubPicker: Loadable {
    
    let payHub: PayHubPicker
    
    init(
        payHub: PayHubPicker
    ) {
        self.payHub = payHub
    }
}

extension PaymentsTransfersModel {
    
    func reload() {
        
        payHub.load()
    }
}
