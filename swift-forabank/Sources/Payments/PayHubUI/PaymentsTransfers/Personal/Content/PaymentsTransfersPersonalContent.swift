//
//  PaymentsTransfersPersonalContent.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersPersonalContent<CategoryPicker, OperationPicker, Toolbar>: ObservableObject {
    
    public let categoryPicker: CategoryPicker
    public let operationPicker: OperationPicker
    public let toolbar: Toolbar
    private let _reload: () -> Void
    
    public init(
        categoryPicker: CategoryPicker,
        operationPicker: OperationPicker,
        toolbar: Toolbar,
        reload: @escaping () -> Void
    ) {
        self.categoryPicker = categoryPicker
        self.operationPicker = operationPicker
        self.toolbar = toolbar
        self._reload = reload
    }
}

public extension PaymentsTransfersPersonalContent {
    
    func reload() {
        
        _reload()
    }
}
