//
//  PaymentsTransfersPersonalContent.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public final class PaymentsTransfersPersonalContent: ObservableObject {
    
    public let categoryPicker: any CategoryPicker
    public let operationPicker: any OperationPicker
    public let transfers: any TransfersPicker
    private let _reload: () -> Void
    
    public init(
        categoryPicker: any CategoryPicker,
        operationPicker: any OperationPicker,
        transfers: any TransfersPicker,
        reload: @escaping () -> Void
    ) {
        self.categoryPicker = categoryPicker
        self.operationPicker = operationPicker
        self.transfers = transfers
        self._reload = reload
    }
}

public extension PaymentsTransfersPersonalContent {
    
    func reload() {
        
        _reload()
    }
}
