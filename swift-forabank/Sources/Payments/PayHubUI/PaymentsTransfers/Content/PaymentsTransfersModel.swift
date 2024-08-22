//
//  PaymentsTransfersModel.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersModel<CategoryPicker, OperationPicker>: ObservableObject {
    
    public let categoryPicker: CategoryPicker
    public let operationPicker: OperationPicker
    
    public init(
        categoryPicker: CategoryPicker,
        operationPicker: OperationPicker
    ) {
        self.categoryPicker = categoryPicker
        self.operationPicker = operationPicker
    }
}
