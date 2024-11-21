//
//  PaymentsTransfersPersonalContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias PaymentsTransfersPersonalContent = PayHubUI.PaymentsTransfersPersonalContent

// MARK: - CategoryPicker

extension CategoryPickerSectionDomain.Binder: PayHubUI.CategoryPicker {}

extension PayHubUI.CategoryPicker {
    
    var sectionBinder: CategoryPickerSectionDomain.Binder? {
        
        return self as? CategoryPickerSectionDomain.Binder
    }
}

// MARK: - OperationPicker

extension OperationPickerBinder: PayHubUI.OperationPicker {}

extension PayHubUI.OperationPicker {
    
    var operationBinder: OperationPickerBinder? {
        
        return self as? OperationPickerBinder
    }
}

// MARK: - TransfersPicker

extension PaymentsTransfersPersonalTransfersDomain.Binder: PayHubUI.TransfersPicker {}

extension PayHubUI.TransfersPicker {
    
    var transfersBinder: PaymentsTransfersPersonalTransfersDomain.Binder? {
        
        return self as? PaymentsTransfersPersonalTransfersDomain.Binder
    }
}

// MARK: - PaymentsTransfersPersonalToolbar

extension PaymentsTransfersPersonalToolbarBinder: PayHubUI.PaymentsTransfersPersonalToolbar {}

extension PayHubUI.PaymentsTransfersPersonalToolbar {
    
    var toolbarBinder: PaymentsTransfersPersonalToolbarBinder? {
        
        return self as? PaymentsTransfersPersonalToolbarBinder
    }
}
