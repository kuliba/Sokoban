//
//  PaymentsTransfersModel.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersModel<CategoryPicker, PayHubPicker>: ObservableObject {
    
    public let categoryPicker: CategoryPicker
    public let payHubPicker: PayHubPicker
    
    public init(
        categoryPicker: CategoryPicker,
        payHubPicker: PayHubPicker
    ) {
        self.categoryPicker = categoryPicker
        self.payHubPicker = payHubPicker
    }
}
