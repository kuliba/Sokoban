//
//  PaymentsTransfersModel.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersModel<CategoryPicker, OperationPicker, Toolbar>: ObservableObject {
    
    public let categoryPicker: CategoryPicker
    public let operationPicker: OperationPicker
    public let toolbar: Toolbar
    
    public init(
        categoryPicker: CategoryPicker,
        operationPicker: OperationPicker,
        toolbar: Toolbar
    ) {
        self.categoryPicker = categoryPicker
        self.operationPicker = operationPicker
        self.toolbar = toolbar
    }
}
