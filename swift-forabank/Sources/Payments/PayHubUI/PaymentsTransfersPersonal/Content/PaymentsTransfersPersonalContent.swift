//
//  PaymentsTransfersPersonalContent.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersPersonalContent<OperationPicker, Toolbar, Transfers>: ObservableObject {
    
    public let categoryPicker: any CategoryPicker
    public let operationPicker: OperationPicker
    public let toolbar: Toolbar
    public let transfers: Transfers
    private let _reload: () -> Void
    
    public init(
        categoryPicker: any CategoryPicker,
        operationPicker: OperationPicker,
        toolbar: Toolbar,
        transfers: Transfers,
        reload: @escaping () -> Void
    ) {
        self.categoryPicker = categoryPicker
        self.operationPicker = operationPicker
        self.toolbar = toolbar
        self.transfers = transfers
        self._reload = reload
    }
}

public extension PaymentsTransfersPersonalContent {
    
    func reload() {
        
        _reload()
    }
}
