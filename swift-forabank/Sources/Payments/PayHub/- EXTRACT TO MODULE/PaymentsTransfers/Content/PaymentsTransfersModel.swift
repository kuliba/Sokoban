//
//  PaymentsTransfersModel.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersModel<PayHubPicker>: ObservableObject
where PayHubPicker: Loadable {
    
    public let payHub: PayHubPicker
    
    public init(
        payHub: PayHubPicker
    ) {
        self.payHub = payHub
    }
}

public extension PaymentsTransfersModel {
    
    func reload() {
        
        payHub.load()
    }
}
