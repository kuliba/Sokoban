//
//  AnywayServicePickerFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI

struct AnywayServicePickerFlowViewFactory<AnywayPaymentFlowView, ServicePicker>
where AnywayPaymentFlowView: View,
      ServicePicker: View {
    
    let makeAnywayFlowView: MakeAnywayFlowView
    let makeServicePicker: MakeServicePicker
}

extension AnywayServicePickerFlowViewFactory {
    
    typealias MakeAnywayFlowView = (AnywayFlowModel) -> AnywayPaymentFlowView
    typealias MakeServicePicker = (PaymentProviderServicePickerModel) -> ServicePicker // PaymentProviderServicePickerWrapperView
}
