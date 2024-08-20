//
//  PaymentsTransfersModel.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersModel<PayHubPicker>: ObservableObject {
    
    public let payHubPicker: PayHubPicker
    
    public init(
        payHubPicker: PayHubPicker
    ) {
        self.payHubPicker = payHubPicker
    }
}
