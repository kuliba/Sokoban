//
//  PaymentsTransfersPersonalContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

// MARK: - CategoryPicker

extension CategoryPickerSectionDomain.Binder: PayHubUI.CategoryPicker {}

extension PayHubUI.CategoryPicker {
    
    var sectionBinder: CategoryPickerSectionDomain.Binder? {
        
        return self as? CategoryPickerSectionDomain.Binder
    }
}

// MARK: - OperationPicker

extension OperationPickerDomain.Binder: PayHubUI.OperationPicker {}

extension PayHubUI.OperationPicker {
    
    var operationBinder: OperationPickerDomain.Binder? {
        
        return self as? OperationPickerDomain.Binder
    }
}

// MARK: - TransfersPicker

extension PaymentsTransfersPersonalTransfersDomain.Binder: PayHubUI.TransfersPicker {}

extension PayHubUI.TransfersPicker {
    
    var transfersBinder: PaymentsTransfersPersonalTransfersDomain.Binder? {
        
        return self as? PaymentsTransfersPersonalTransfersDomain.Binder
    }
}
