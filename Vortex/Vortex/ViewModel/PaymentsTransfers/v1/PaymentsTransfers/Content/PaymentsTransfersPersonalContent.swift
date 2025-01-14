//
//  PaymentsTransfersPersonalContent.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

// MARK: - CategoryPicker

extension CategoryPickerSectionDomain.Binder: CategoryPicker {}

extension CategoryPicker {
    
    var sectionBinder: CategoryPickerSectionDomain.Binder? {
        
        return self as? CategoryPickerSectionDomain.Binder
    }
}

// MARK: - OperationPicker

extension OperationPickerDomain.Binder: OperationPicker {}

extension OperationPicker {
    
    var operationBinder: OperationPickerDomain.Binder? {
        
        return self as? OperationPickerDomain.Binder
    }
}

// MARK: - TransfersPicker

extension PaymentsTransfersPersonalTransfersDomain.Binder: TransfersPicker {}

extension TransfersPicker {
    
    var transfersBinder: PaymentsTransfersPersonalTransfersDomain.Binder? {
        
        return self as? PaymentsTransfersPersonalTransfersDomain.Binder
    }
}
