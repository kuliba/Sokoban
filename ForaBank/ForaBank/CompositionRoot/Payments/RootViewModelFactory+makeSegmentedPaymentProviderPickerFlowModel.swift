//
//  RootViewModelFactory+makeSegmentedPaymentProviderPickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import ForaTools
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeSegmentedPaymentProviderPickerFlowModel(
        multi: MultiElementArray<SegmentedOperatorProvider>,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) -> SegmentedPaymentProviderPickerFlowModel {
        
        let make = makeSegmentedPaymentProviderPickerFlowModel(
            pageSize: settings.pageSize
        )
        
        return make(multi, qrCode, qrMapping)
    }
}
