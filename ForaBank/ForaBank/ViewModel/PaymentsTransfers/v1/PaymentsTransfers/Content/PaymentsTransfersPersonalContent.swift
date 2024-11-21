//
//  PaymentsTransfersPersonalContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias PaymentsTransfersPersonalContent = PayHubUI.PaymentsTransfersPersonalContent<PaymentsTransfersPersonalToolbarBinder, PaymentsTransfersPersonalTransfersDomain.Binder>

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
